--Step 1: Create, upload, and verify tables

--Create dataset
CREATE DATABASE ecommerce_customer_churn1;

--Create customer table
CREATE TABLE customer (
    customer_id TEXT PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    username TEXT,
    email TEXT,
    gender TEXT,
    birthdate DATE,
    device_type TEXT,
    device_id TEXT,
    device_version TEXT,
    home_location_lat FLOAT,
    home_location_long FLOAT,
    home_location TEXT,
    home_country TEXT,
    first_join_date DATE
);

--Verify customer table
SELECT * FROM customer;

--Create transactions table
CREATE TABLE transactions (
    created_at TIMESTAMP,
    customer_id TEXT,
    booking_id TEXT PRIMARY KEY,
    session_id TEXT,
    product_metadata TEXT,
    payment_method TEXT,
    payment_status TEXT,
    promo_amount FLOAT,
    promo_code TEXT,
    shipment_fee FLOAT,
    shipment_date_limit TIMESTAMP,
    shipment_location_lat FLOAT,
    shipment_location_long FLOAT,
    total_amount FLOAT
);

--Verify transactions table
SELECT * FROM transactions;

--Create click_stream table
CREATE TABLE click_stream (
    session_id TEXT,
    event_name TEXT,
    event_time TIMESTAMP,
    event_id TEXT,
    traffic_source TEXT,
    event_metadata TEXT
);

--Verify click_stream table
SELECT * FROM click_stream;

--Create product table
CREATE TABLE product (
    id TEXT PRIMARY KEY,
    gender TEXT,
    masterCategory TEXT,
    subCategory TEXT,
    articleType TEXT,
    baseColour TEXT,
    season TEXT,
    year INT,
    usage TEXT,
    productDisplayName TEXT
);

--The original CSV file contained a data inconsistency where some rows had an extra comma, resulting in a column mismatch. 
--This caused SQL to throw an error during the import. To resolve this, the raw file was processed and cleaned in a separate Python script. 
--This script merged the final two columns into a single column, ensuring a consistent 10-column structure across all rows.

--Verify product table
SELECT * FROM product;


--Step 2: Data Preparation and Cleaning
--Dividing the product_metadata column from the transactions table into three new columns for more simplified data usage
ALTER TABLE transactions
ADD COLUMN product_id TEXT,
ADD COLUMN quantity INT,
ADD COLUMN item_price NUMERIC;

--Extract values from product_metadata into new columns
UPDATE transactions
SET
    product_id = (product_metadata::jsonb -> 0 ->> 'product_id')::TEXT,
    quantity = ((product_metadata::jsonb -> 0 ->> 'quantity')::INT),
    item_price = ((product_metadata::jsonb -> 0 ->> 'item_price')::NUMERIC);
	
--Check table after update
SELECT * FROM transactions;

--Doing the same with event_metadata from click_stream table
ALTER TABLE click_stream
ADD COLUMN product_id TEXT,
ADD COLUMN quantity INTEGER,
ADD COLUMN item_price NUMERIC;

--Extract values from event_metadata into new columns
--Note: The UPDATE query could not be executed in the same way as the previous one because the JSON format in this column is different. 
--The event_metadata column contains a single JSON object ({}) instead of an array ([{}]).
UPDATE click_stream
SET
    product_id = (REPLACE(event_metadata, '''', '"')::jsonb ->> 'product_id'),
    quantity = (REPLACE(event_metadata, '''', '"')::jsonb ->> 'quantity')::INT,
    item_price = (REPLACE(event_metadata, '''', '"')::jsonb ->> 'item_price')::NUMERIC;
	
--Check table after update
--Note: Only observations with an "add to cart" event name have information in the event metadata
SELECT * FROM click_stream
WHERE event_name = 'ADD_TO_CART';


--Add new column for transactions date only
ALTER TABLE transactions
ADD COLUMN transaction_date DATE;

--Populate transaction_date with only the date of purchase (without the time of the transaction)
UPDATE transactions
SET transaction_date = created_at::DATE;


--Step 3: Defining a churn rule
--Calculating the total purchases per customer and the average time between purchases

ALTER TABLE customer
ADD COLUMN total_purchases INT,
ADD COLUMN avg_days_between_purchases DECIMAL(10,2);

--Calculating total purchases per customer
UPDATE customer
SET total_purchases = COALESCE(transaction_counts.purchase_count, 0)
FROM (
    SELECT customer_id, COUNT(*) AS purchase_count
    FROM transactions
    GROUP BY customer_id
) AS transaction_counts
WHERE customer.customer_id = transaction_counts.customer_id;

SELECT * FROM customer;


--I realized that not all customers had made a purchase
--To address this, i will perform a verification to determine if the number of customers in the customers table is different from the number of customers in the transactions table.
SELECT
    COUNT(DISTINCT customer_id) AS total_unique_customers
FROM
    customer;
--result: 100K customers in customer table

SELECT
    COUNT(DISTINCT customer_id) AS total_customers_with_purchases
FROM
    transactions;
--result: 50K customers in transactions table

--Other verifications
SELECT * FROM customer
ORDER BY 
	customer_id;

SELECT *
FROM transactions
WHERE customer_id = '10004';

SELECT
    DISTINCT customer_id
FROM
    transactions
ORDER BY 
	customer_id;


--Creating a new column in the customers table to indicate whether a customer has made a purchase from the company
ALTER TABLE customer
ADD column ever_purchased TEXT;


UPDATE customer
SET ever_purchased = 'yes'
WHERE customer_id IN (
    SELECT DISTINCT customer_id
    FROM transactions
);

UPDATE customer
SET ever_purchased = 'no'
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM transactions
);

SELECT * FROM customer;


--Calculating the average time between purchases
WITH diffs AS (
    SELECT 
        customer_id,
        transaction_date - LAG(transaction_date) 
            OVER (PARTITION BY customer_id ORDER BY transaction_date) AS diff_days
    FROM transactions
),
avg_diffs AS (
    SELECT 
        customer_id,
        AVG(diff_days) AS avg_diff
    FROM diffs
    WHERE diff_days IS NOT NULL
    GROUP BY customer_id
)
UPDATE customer
SET avg_days_between_purchases = avg_diffs.avg_diff
FROM avg_diffs
WHERE customer.customer_id = avg_diffs.customer_id;

--Verifications
SELECT * FROM customer
ORDER BY customer_id;

SELECT ever_purchased, COUNT(*) AS total_customers
FROM customer
GROUP BY ever_purchased;

--Result: The total number of customers who have made a purchase is 50K in the customers table, 
--which equals the total number of customers who appear in the transactions table

--Calculating the average of the average time between purchases for customers with 3 or more purchases 
SELECT AVG(avg_days_between_purchases) AS avg_days_overall
FROM customer
WHERE total_purchases >= 3;

--Result: 112 days

--Creating a churn status column
ALTER TABLE customer
ADD COLUMN churn_status TEXT;

--Verifications
--The first transaction recorded: 30/06/2016
SELECT *
FROM transactions
ORDER BY transaction_date ASC
LIMIT 1;

--The most recent transaction recorded: 31/07/2022
SELECT *
FROM transactions
ORDER BY transaction_date DESC
LIMIT 1;

--Note: Since I am using a 2022 dataset, I will take the last record as the current day. 
--If the data were live, I would use the current date as my reference point

--Here is the final logic to consider a customer active:
--Their total_purchases >= 3 and avg_days_between_purchases is > than the time from their last purchase to the most recent transaction date (31/07/2022).
--Their total_purchases < 3 and avg_days_between_purchases < 112 (the average of the average time between purchases)

--All other customers are considered inactive.

--Adding the last purchase date per customer for reference
ALTER TABLE customer
ADD COLUMN last_purchase_date DATE;

UPDATE customer
SET last_purchase_date = t.last_transaction_date
FROM (
    SELECT customer_id, MAX(transaction_date) AS last_transaction_date
    FROM transactions
    GROUP BY customer_id
) t
WHERE customer.customer_id = t.customer_id;

--Verification
SELECT * FROM customer
ORDER BY 
	customer_id;

--Populating churn status
WITH last_purchase AS (
    SELECT 
        customer_id,
        MAX(transaction_date) AS last_transaction_date
    FROM transactions
    GROUP BY customer_id
),
max_transaction AS (
    SELECT MAX(transaction_date) AS max_date
    FROM transactions
)
UPDATE customer
SET churn_status = CASE
    WHEN total_purchases >= 3 
         AND avg_days_between_purchases > (SELECT max_date FROM max_transaction) - lp.last_transaction_date
        THEN 'active'
    WHEN total_purchases < 3 
         AND avg_days_between_purchases < 112
        THEN 'active'
    ELSE 'inactive'
END
FROM last_purchase lp
WHERE customer.customer_id = lp.customer_id;

--Verifying
SELECT * FROM customer
ORDER BY 
	customer_id;
