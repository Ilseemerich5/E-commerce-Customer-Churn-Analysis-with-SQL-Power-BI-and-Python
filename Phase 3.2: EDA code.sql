--Step 4: Important insights
--Note: I will be using CREATE VIEW in order to save the insights and consult them again if needed

--Churn status count
CREATE VIEW churn_status_summary AS
SELECT
    churn_status,
    COUNT(*) AS total_customer
FROM
    customer
GROUP BY
    churn_status;

--Results:
--49k "customers" never purchased
--27K customers are considered inactive
--22K customers are considered active

--Gender per churn status
CREATE VIEW churn_status_gender AS
SELECT 
    churn_status,
    COUNT(*) AS total_customers,
    COUNT(CASE WHEN gender = 'F' THEN 1 END) AS female_count,
    ROUND(100.0 * COUNT(CASE WHEN gender = 'F' THEN 1 END) / COUNT(*), 2) AS female_pct,
    COUNT(CASE WHEN gender = 'M' THEN 1 END) AS male_count,
    ROUND(100.0 * COUNT(CASE WHEN gender = 'M' THEN 1 END) / COUNT(*), 2) AS male_pct
FROM customer
WHERE gender IN ('F', 'M')
GROUP BY churn_status;

--Conclusion:
--The customer base is predominantly inactive, with 27,717 inactive customers compared to 22,988 active ones. 
--Despite this significant difference in activity status, the gender distribution is nearly identical between both groups, 
--suggesting that gender is not a factor influencing customer inactivity

--Location per churn status
CREATE VIEW churn_status_location AS
SELECT
    home_location,
    COUNT(*) FILTER (WHERE churn_status = 'active') AS active_count,
    COUNT(*) FILTER (WHERE churn_status = 'inactive') AS inactive_count,
    COUNT(*) FILTER (WHERE churn_status IS NULL) AS null_churn_count,
    COUNT(*) AS total_customers
FROM customer
GROUP BY home_location
ORDER BY total_customers DESC;


--Top 10 active customers per location
CREATE VIEW churn_status_location_top10 AS
SELECT
    home_location,
    COUNT(*) AS active_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customer WHERE churn_status = 'active'), 2) AS active_pct_of_total
FROM customer
WHERE churn_status = 'active'
GROUP BY home_location
ORDER BY active_pct_of_total DESC
LIMIT 10;

--Conclusion: 
--The top 10 list shows that customer activity is highly concentrated in a few locations. 
--The five top locations are all on the island of Jawa, with Jakarta Raya alone accounting for over 18% of all active customers. 
--This suggests that the active customer base is very geographically concentrated.


--Finding customers at risk of leaving by checking two conditions: 
--they've either made fewer than 3 total purchases or haven't bought anything in over 90 days.
CREATE VIEW customers_at_risk AS
SELECT
    customer_id,
    total_purchases,
    avg_days_between_purchases,
    last_purchase_date
FROM
    customer
WHERE
    total_purchases < 3
    OR DATE_PART('day', NOW() - last_purchase_date) > 90;

--Conclusion:
--For more effective retention and reactivation, the company could focus their strategies on the at-risk customer segment 
--by implementing targeted and personalized campaigns in key geographic locations. 
--This dual approach is essential to both win back former customers and reinforce loyalty among the most active users.
	
--Average spend per customer
CREATE VIEW average_spend_per_customer AS
SELECT 
    customer_id,
    AVG(total_amount) AS avg_transaction_amount,
    SUM(total_amount) AS total_spent
FROM transactions
GROUP BY customer_id;

--Top 10 best customers
CREATE VIEW top_best_customers AS
SELECT * FROM average_spend_per_customer
ORDER BY total_spent DESC
LIMIT 10;

--Top 10 worst curstomers
CREATE VIEW top_worst_customers AS
SELECT * FROM average_spend_per_customer
ORDER BY total_spent ASC
LIMIT 10;

--Conclusion:
--To maximize value, the company could segment customers by their monetary worth. 
--The focus should be on retaining high-value clients and understanding their behavior to attract similar customers. 
--At the same time, the low-spending group represents a key opportunity for growth, and they should be targeted with specific strategies designed to increase their spending.

--Usage of promotions and its relationship with churn
CREATE VIEW promotions_relationship_with_churn AS
SELECT 
    promo_code,
    COUNT(*) AS promo_usage,
    SUM(CASE WHEN c.churn_status = 'active' THEN 1 ELSE 0 END) AS active_customers,
    SUM(CASE WHEN c.churn_status = 'inactive' THEN 1 ELSE 0 END) AS inactive_customers
FROM transactions t
LEFT JOIN customer c ON t.customer_id = c.customer_id
WHERE promo_code IS NOT NULL
GROUP BY promo_code
ORDER BY promo_usage DESC;

--Conclusion:
--For every active customer who used a promo, there was almost one inactive customer who did the same. 
--This suggests that discounts are attracting a customer base that seeks out temporary deals rather than long-term loyalty.

--Pyament methods and status
CREATE VIEW payment_methods AS
SELECT 
    payment_method,
    payment_status,
    COUNT(*) AS total_transactions,
    AVG(total_amount) AS avg_amount
FROM transactions
GROUP BY payment_method, payment_status
ORDER BY total_transactions DESC;

--Conclusion:
--The company should keep focusing on Credit Card, while also supporting Gopay and OVO 
--as strong alternatives. At the same time, it should work on reducing failures to improve overall payment success.

--Customers who have never purchased and their activity in the clickstream table (on the website)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.churn_status,
    cs.session_id,
    cs.event_name,
    cs.event_time,
    cs.traffic_source
FROM customer c
JOIN transactions t 
    ON c.customer_id = t.customer_id
JOIN click_stream cs
    ON t.session_id = cs.session_id
WHERE c.churn_status IS NULL
ORDER BY c.customer_id, cs.event_time;

--This analysis is not possible because the clickstream data cannot be linked to customers. 
--The click_stream table only contains a session_id, which can be joined to transactions. 
--However, since customers who have never made a purchase do not exist in the transactions table, their web activity is not visible. 
--In conclusion, we cannot analyze the on-site behavior of visitors who did not buy.


--Behavior in the website (click_stream) per churn status
CREATE VIEW web_behavior_per_churn_status AS
SELECT 
    cs.event_name,
    COUNT(CASE WHEN c.churn_status = 'active' THEN 1 END) AS active_count,
    COUNT(CASE WHEN c.churn_status = 'inactive' THEN 1 END) AS inactive_count
FROM customer c
JOIN transactions t 
    ON c.customer_id = t.customer_id
JOIN click_stream cs
    ON t.session_id = cs.session_id
WHERE c.churn_status IN ('active', 'inactive')
GROUP BY cs.event_name
ORDER BY cs.event_name;

--Conclusion:
--While ADD_TO_CART shows higher counts among inactive users (1.97M vs. 1.81M actives), 
--indicating strong initial interest that often drops off, BOOKING tells the opposite story, 
--with more active users completing the action (928K vs. 777K inactives). 
--This contrast highlights that inactive users frequently abandon at the cart stage, 
--whereas active users are more likely to follow through to booking, suggesting the key gap lies 
--in converting inactive cart users into confirmed bookings

--Recomendation:
--Focus retention strategies on the cart stage: implement personalized reminders, targeted discounts, 
--or a smoother checkout experience to re-engage those who show intent but abandon before booking. 
--This would directly address the point where churn is most evident and could help recover high-intent users


--Comparison of the time between the first event and purchase
WITH first_events AS (
    SELECT 
        c.customer_id,
        c.churn_status,
        MIN(cs.event_time) AS first_event_time
    FROM customer c
    JOIN transactions t 
        ON c.customer_id = t.customer_id
    JOIN click_stream cs
        ON t.session_id = cs.session_id
    WHERE c.churn_status IN ('active', 'inactive')
    GROUP BY c.customer_id, c.churn_status
),
first_purchases AS (
    SELECT 
        t.customer_id,
        MIN(t.created_at) AS first_purchase_time
    FROM transactions t
    GROUP BY t.customer_id
)
SELECT 
    f.churn_status,
    AVG(EXTRACT(EPOCH FROM (fp.first_purchase_time - f.first_event_time)) / 86400) AS avg_days_to_purchase
FROM first_events f
JOIN first_purchases fp 
    ON f.customer_id = fp.customer_id
GROUP BY f.churn_status;
--First event = MIN(event_time) from click_stream.
--First purchase = MIN(created_at) from transactions (ideally with payment_status = 'paid')

--The same but in minutes (not days)
CREATE VIEW time_to_purchase_from_first_event AS
SELECT
    c.customer_id,
    MIN(cs.event_time) AS first_event_time,
    MIN(t.created_at) AS first_purchase_time,
    EXTRACT(EPOCH FROM (MIN(t.created_at) - MIN(cs.event_time))) / 60 AS minutes_to_first_purchase
FROM customer c
LEFT JOIN transactions t ON t.customer_id = c.customer_id
LEFT JOIN click_stream cs ON cs.session_id = t.session_id
GROUP BY c.customer_id
ORDER BY minutes_to_first_purchase;

--Average of minutes to fisrt purchase
SELECT
    AVG(minutes_to_first_purchase) AS average_minutes_to_purchase
FROM
    time_to_purchase_from_first_event;
--Result: In average it takes the customer 31 minutes to purchase an item from the website

--Average of minutes to first purchase per churn status
SELECT
    churn_status,
    AVG(minutes_to_first_purchase) AS avg_minutes_to_first_purchase
FROM (
    SELECT
        c.customer_id,
        c.churn_status,
        EXTRACT(EPOCH FROM (MIN(t.created_at) - MIN(cs.event_time))) / 60 AS minutes_to_first_purchase
    FROM customer c
    LEFT JOIN transactions t ON t.customer_id = c.customer_id
    LEFT JOIN click_stream cs ON cs.session_id = t.session_id
    WHERE c.churn_status IS NOT NULL
    GROUP BY c.customer_id, c.churn_status
) AS per_customer
GROUP BY churn_status
ORDER BY churn_status;
--Result: the average is almost the same (31 minutes)

--Conclusion:
--There is an opportunity to shorten and simplify the cart-to-booking process, 
--as decisions are made quickly, and reducing friction within those 31 minutes could 
--significantly increase conversions


--Identifying the most common events performed by users who did not make a purchase
--This joins the click_stream data with the transactions table to find all website sessions.
--By filtering for rows where the transaction's session_id is NULL, it isolates only the sessions that never resulted in a purchase.
SELECT
    cs.event_name,
    COUNT(*) AS event_count
FROM click_stream cs
LEFT JOIN transactions t
    ON cs.session_id = t.session_id
WHERE t.session_id IS NULL -- sessions with no corresponding transaction
GROUP BY cs.event_name
ORDER BY event_count DESC;
--Result: We see that 85K customers add an item to the cart without purchasing it later

--Identifying the most common events performed by users who did not make a purchase in the las 3 months
CREATE VIEW common_events_no_purchase_last_3_months AS
SELECT
    cs.event_name,
    COUNT(*) AS event_count
FROM
    click_stream cs
LEFT JOIN
    transactions t ON cs.session_id = t.session_id
WHERE
    t.session_id IS NULL  -- sessions with no corresponding transaction
    AND cs.event_time >= '2022-05-01'
    AND cs.event_time <= '2022-07-31'
GROUP BY
    cs.event_name
ORDER BY
    event_count DESC;
--Result: We see that 1380 customers add an item to the cart without purchasing it later

--Comparison of purchases with and without a promotion
CREATE VIEW promotional_vs_non_promotional_purchases AS
SELECT 
    CASE 
        WHEN promo_amount > 0 OR promo_code IS NOT NULL THEN 'With Promotion'
        ELSE 'Without Promotion'
    END AS promotion_status,
    COUNT(*) AS total_purchases
FROM transactions
GROUP BY promotion_status;

--Comparison of purchases with and without a promotion with churn status
CREATE VIEW promotional_vs_non_promotional_purchases_churn_status AS
SELECT 
    c.churn_status,
    CASE 
        WHEN t.promo_amount > 0 OR t.promo_code IS NOT NULL THEN 'With Promotion'
        ELSE 'Without Promotion'
    END AS promotion_status,
    COUNT(*) AS total_purchases
FROM transactions t
JOIN customer c ON t.customer_id = c.customer_id
GROUP BY c.churn_status, promotion_status
ORDER BY c.churn_status, promotion_status;

--Conclusion:
--Most of the customers are willing to purchase at full price, which means that the company doesn't 
--need to rely on discounts for the majority of our revenue. They can use promotions more strategically, 
--to achieve specific business goals, such as attracting new customers, reactivating inactive ones, 
--or incentivizing most loyal customers to spend more


--Most sold products by category
CREATE VIEW most_sold_products_by_category AS 
SELECT 
    p.masterCategory,
    p.subCategory,
    COUNT(t.product_id) AS total_sold,
    SUM(t.quantity) AS total_quantity,
    SUM(t.total_amount) AS total_revenue
FROM transactions t
JOIN product p ON t.product_id = p.id
GROUP BY p.masterCategory, p.subCategory
ORDER BY total_sold DESC;

--Popularity by color and season
CREATE VIEW color_popularity_by_season AS 
SELECT 
    baseColour,
    season,
    COUNT(*) AS total_sold,
    SUM(total_amount) AS revenue
FROM transactions t
JOIN product p ON t.product_id = p.id
GROUP BY baseColour, season
ORDER BY total_sold DESC;

--Event frequency in the website before abandonment (churn)
CREATE VIEW event_frequency_before_abandonment AS 
SELECT 
    cs.event_name,
    COUNT(*) AS event_count
FROM click_stream cs
JOIN transactions t ON cs.session_id = t.session_id
JOIN customer c ON t.customer_id = c.customer_id
WHERE c.churn_status = 'inactive'
GROUP BY cs.event_name
ORDER BY event_count DESC;


--Products most added to the cart by inactive customers 
CREATE VIEW inactive_customer_most_added_products AS 
SELECT
    p.productdisplayname,
    COUNT(*) AS add_to_cart_count
FROM
    click_stream cs
JOIN
    transactions t ON cs.session_id = t.session_id
JOIN
    customer c ON t.customer_id = c.customer_id
JOIN
    product p ON t.product_id = p.id
WHERE
    cs.event_name = 'ADD_TO_CART' AND c.churn_status = 'inactive'
GROUP BY
    p.productdisplayname
ORDER BY
    add_to_cart_count DESC;
	

--Best-selling products by active customers
CREATE VIEW best_selling_products_by_active_customers AS 
SELECT
    p.productdisplayname,
    COUNT(t.product_id) AS total_sales
FROM
    customer c
JOIN
    transactions t ON c.customer_id = t.customer_id
JOIN
    product p ON t.product_id = p.id
WHERE
    c.churn_status = 'active'
GROUP BY
    p.productdisplayname
ORDER BY
    total_sales DESC
LIMIT 10;


--Comparison of products most added to the cart by inactive customers versus best-selling products by active customers
CREATE VIEW product_behavior_comparison AS
WITH inactive_customer_cart AS (
    SELECT
        p.productdisplayname AS product_name,
        COUNT(*) AS add_to_cart_count,
        ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS rn
    FROM
        click_stream cs
    JOIN
        transactions t ON cs.session_id = t.session_id
    JOIN
        customer c ON t.customer_id = c.customer_id
    JOIN
        product p ON t.product_id = p.id
    WHERE
        cs.event_name = 'ADD_TO_CART' AND c.churn_status = 'inactive'
    GROUP BY
        p.productdisplayname
),
active_customer_sales AS (
    SELECT
        p.productdisplayname AS product_name,
        COUNT(t.product_id) AS total_sales,
        ROW_NUMBER() OVER (ORDER BY COUNT(t.product_id) DESC) AS rn
    FROM
        customer c
    JOIN
        transactions t ON c.customer_id = t.customer_id
    JOIN
        product p ON t.product_id = p.id
    WHERE
        c.churn_status = 'active'
    GROUP BY
        p.productdisplayname
)
SELECT
    al.product_name AS active_customer_product,
    al.total_sales,
    il.product_name AS inactive_customer_product,
    il.add_to_cart_count
FROM
    active_customer_sales al
FULL OUTER JOIN
    inactive_customer_cart il ON al.rn = il.rn
ORDER BY
    COALESCE(al.rn, il.rn);

--Conclusion:
--The products most added to the cart by inactive customers are largely the same ones that active 
--customers buy most frequently, with "Lucera Women Silver Earrings" topping both lists. 
--This indicates that inactive customers have a strong desire to purchase but are failing to convert. 
--The business should use this information to its advantage by implementing a targeted
--re-engagement strategy that offers promotions specifically on these desired items to win those 
--customers back and recapture lost revenue.
