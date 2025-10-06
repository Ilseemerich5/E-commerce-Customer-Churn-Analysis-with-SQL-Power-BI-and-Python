# E-commerce-Customer-Churn-Analysis-with-SQL-Power-BI-and-Python
## Description
This project analyzes customer behavior on an Indonesian e-commerce platform to identify factors driving churn and propose effective retention strategies. The analysis covers over 850,000 transactions from 2016 to 2022, integrating 4 primary data sources: customers, transactions, products, and clickstream data.  

The workflow follows a structured process: **Business Understanding → ETL → EDA → Visualization → Modeling**, transforming raw data into actionable business insights.

## Tools
- **PostgreSQL**: ETL, data cleaning, SQL views for consistent analysis  
- **Python**: Data cleaning and preprocessing 
- **Power BI**: Interactive dashboards, age-range segmentation in M (Power Query), dynamic measures in DAX  

## Dataset
- Customer transactions 
- Product information  
- Clickstream data (website interactions)  
- Customer demographic data  
> Note: Data was cleaned and consolidated into an analysis-ready dataset using SQL and Python. Product CSV files were standardized to ensure uniform columns.  

## Business Understanding
- Objective: Identify factors driving customer churn and propose effective retention strategies  
- Scope: Analyze transactional, product, customer, and website interaction data  
- Key Questions:  
  - Which customers are likely to churn?  
  - What behavioral patterns differentiate active and inactive customers?  
  - How can the business improve retention for high-value segments?  

## Methodology

### ETL (Data Cleaning & Transformation)
- Merge, clean, and standardize datasets  
- Ensure uniformity of product.csv file  

### Exploratory Data Analysis (EDA)
- Identify churn patterns and key customer segments  
- Key insights:  
  - 42% of customers inactive in 2022  
  - VIP customers generate majority of revenue  
  - Most active customers: Jakarta Raya & Java, women aged 25–34  

### Churn Rule Definition
- Customers with total purchases ≥ 3 and average time between purchases > time since last purchase → Active  
- Customers with total purchases < 3 and average time between purchases < 112 days → Active  
- All others → Inactive  

### Visualization & Reporting
- Power BI dashboards with dynamic measures and segmentation  
- SQL CREATE VIEW for consistent reporting  

## Key KPIs
- Churn rate  
- Purchase frequency  
- Website engagement  
- Retention by customer segment  

## Next Steps
- Develop a predictive model (Random Forest) to anticipate churn  
- Optimize retention strategies  
- Enhance customer loyalty  

## Author
- Ilse EMERICH
