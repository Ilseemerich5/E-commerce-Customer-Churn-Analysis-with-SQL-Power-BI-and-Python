# Phase 2: ETL (Extract, Transform, Load)

## ETL Process

The objective of this phase was to integrate and prepare the different data sources for analysis, ensuring consistency and quality. The entire process was implemented in **PostgreSQL** and **Python using Google Colab** to leverage database management capabilities, query processing, and flexible data manipulation.

### 1. Database and Table Creation
- The main tables were defined in PostgreSQL: Customers, Transactions, Products, and Click Stream.
- For uploading the **Products** table, a prior modification was made in Python:
  - The original CSV file contained a data inconsistency where some rows had an extra comma, resulting in a column mismatch.
  - This caused SQL to throw an error during the import.
  - To resolve this, the raw file was processed and cleaned in a separate Python script in Google Colab.
  - This script merged the final two columns into a single column, ensuring a consistent 10-column structure across all rows.

### 2. Data Cleaning and Transformation
- Columns in JSON format (product_id, quantity, item_price) were transformed into structured and analyzable data using Python.

### 3. Key Variable Generation
- **total_purchases**: Total number of purchases per customer.
- **avg_days_between_purchases**: Average number of days between purchases.
  - Calculated for each customer.
  - For customers with 3 or more purchases, calculated the average of their average time between purchases, resulting in 112 days.
- **days_since_last_purchase**: Number of days since each customer's last purchase.
- **transaction_date_only**: Extracted date component from transaction timestamps (without time) for analysis.
- **last_purchase_date**: Added the last purchase date per customer as a reference point.
- **churn_status**: Created a column to classify customers as active or inactive following the final churn logic:
  1. Customers with total_purchases >= 3 and avg_days_between_purchases greater than the time since their last purchase up to the most recent transaction date → active.
  2. Customers with total_purchases < 3 and avg_days_between_purchases < 112 → active.
  3. All other customers → inactive.
  - **Note**: Since the dataset is from 2022, the last record was used as the current reference date. In a live dataset, the current date would be used.
- **ever_purchased**: Added a column in the Customers table to indicate whether the customer has ever made a purchase, addressing the 50K customers who have transactions versus 100K total customers in the table.

## Outcome
- A clean and structured dataset was obtained, enabling descriptive analysis and preparation for visualization or modeling.
- The quality and consistency of the data ensure reliability in subsequent findings and metrics.
