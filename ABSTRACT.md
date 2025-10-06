# Abstract

This project analyzes customer behavior on an Indonesian e-commerce platform, with the goal of identifying factors driving churn and proposing effective retention strategies. The analysis was conducted on a dataset of over 850,000 transactions from 2016 to 2022, integrating 4 primary data sources: customers, transactions, products, and clickstream data. These datasets were cleaned and consolidated through an ETL process using SQL and Python, producing a consistent, analysis-ready dataset. Specifically, in Python, the product.csv file was standardized by merging the last two columns in rows where extra commas had created an 11th column, ensuring uniformity across the dataset.

The EDA (Exploratory Data Analysis) revealed that approximately 42% of customers were considered inactive in 2022, while a small group of VIP customers generated the majority of revenue. Most active customers were concentrated in Jakarta Raya and Java regions, predominantly young women aged 25 to 34. Behavioral patterns differentiating active and inactive customers were identified, including purchase frequency, website interaction, and response to promotions.

A churn rule was established based on customers’ purchase history and transaction frequency:

1. Customers with total purchases ≥ 3 and an average time between purchases greater than the period since their last purchase up to the most recent transaction date are considered active.  
2. Customers with total_purchases < 3 and an average time between purchases < 112 days are considered active. The threshold of 112 days was calculated as the average of the average time between purchases for customers with 3 or more purchases.  
3. All other customers are classified as inactive.

To communicate the findings, a Power BI dashboard was developed, featuring age-range segmentation created in M (Power Query), dynamic measures implemented in DAX, and tables generated with CREATE VIEW in SQL to ensure consistent and reliable analysis.

The next steps I recommend include developing a predictive model using Random Forest to anticipate churn in the coming months, optimizing retention strategies, and enhancing customer loyalty.
