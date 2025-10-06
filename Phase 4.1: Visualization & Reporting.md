# Phase 4: Visualization & Reporting

## Power BI Dashboard – Customer Churn Analysis

This phase presents the insights obtained from the analysis through an **interactive Power BI dashboard**.

**View the dashboard here:**  
[Open Dashboard in Power BI](https://app.powerbi.com/groups/me/reports/d37aa858-94ea-4e65-b74a-9e970df48d61/79d286c3418c04c89a05?experience=power-bi)

---

## Dashboard Screenshots (Filtered for 2022 Data)

### Overview
![Dashboard Overview](https://raw.githubusercontent.com/Ilseemerich5/E-commerce-Customer-Churn-Analysis-with-SQL-Power-BI-and-Python/main/Phase%204.2%3A%20Dashboard%20Overview%20(2022).png)

### Products & Discounts
![Dashboard Products & Discounts](https://raw.githubusercontent.com/Ilseemerich5/E-commerce-Customer-Churn-Analysis-with-SQL-Power-BI-and-Python/main/Phase%204.3%3A%20Dashboard%20Products%20%26%20Discounts%20(2022).png)

---

## Data Transformations and Preparations

### 1. Power Query (M)
- **Creation of Age and Age Range column** to segment customers:

```m
= Table.AddColumn(public_customer, "age", each Date.Year(#date(2022, 7, 31)) - Date.Year([birthdate]))

= Table.AddColumn(#"Personnalisée ajoutée", "age_range", each if [age] >= 5 and [age] <= 14 then "5-14"
else if [age] >= 15 and [age] <= 24 then "15-24"
else if [age] >= 25 and [age] <= 34 then "25-34"
else if [age] >= 35 and [age] <= 44 then "35-44"
else if [age] >= 45 and [age] <= 54 then "45-54"
else if [age] >= 55 and [age] <= 70 then "55-70"
else "Out of Range")
```
---


## 2. DAX Measures

A dedicated **Measures Table** was created in Power BI to store all key calculations.

### Measures included:

- `total_amount = SUM('public transactions'[total_amount])`
- `Active customers = CALCULATE (COUNTROWS ( 'public customer'),'public customer'[churn_status] = "active")`
- `% of Churn = DIVIDE( CALCULATE(COUNTROWS('public customer'),'public customer'[churn_status] = "inactive"),COUNTROWS(FILTER('public customer','public customer'[churn_status] IN {"active", "inactive"})))`
- `avg_amount_per_purchase = AVERAGE('public transactions'[total_amount])`
- `dif_product_purchased = DISTINCTCOUNT('public transactions'[product_id])`
- `First Transaction Recorded = MIN ('public transactions'[transaction_date])`
- `Inactive customers = CALCULATE (COUNTROWS ( 'public customer'),'public customer'[churn_status] = "inactive")`
- `Most Recent Transaction =MAX ( 'public transactions'[transaction_date])`
- `Total Rows Customers = COUNTROWS('public customer')`
- `Total Transactions = COUNTROWS('public transactions')`



## 3. SQL Integration

Views (`CREATE VIEW`) added to Power BI for consistent and efficient analysis:

- `average_spend_per_customer`
- `payment_method`
- `time_to_purchase_from_first_event`
- `top_best_customers`

### Visualizations

- Customer distribution by age range.
- Cumulative revenue per customer (top 10).
- Churn by demographic segment.
- Purchase distribution by category.
- Geographic map of active and inactive customers.


