# Phase 4: Visualization & Reporting

## Power BI Dashboard – Customer Churn Analysis

This phase presents the insights obtained from the analysis through an **interactive Power BI dashboard**.

**View the dashboard here:**  
[Open Dashboard in Power BI](https://app.powerbi.com/groups/me/reports/d37aa858-94ea-4e65-b74a-9e970df48d61/79d286c3418c04c89a05?experience=power-bi)

---

## Dashboard Screenshots (Filtered for 2022 Data)

### Overview
![Dashboard Overview](https://raw.githubusercontent.com/Ilseemerich5/E-commerce-Customer-Churn-Analysis-with-SQL-Power-BI-and-Python/main/Dashboard%20Overview%20(2022).png)

### Products & Discounts
![Dashboard Products & Discounts](https://raw.githubusercontent.com/Ilseemerich5/E-commerce-Customer-Churn-Analysis-with-SQL-Power-BI-and-Python/main/Dashboard%20Products%20&%20Discounts%20(2022).png)
---

## Data Transformations and Preparations

### 1. Power Query (M)
- **Creation of “Age Range” column** to segment customers:

```m
if [Edad] < 18 then "Menor de 18"
else if [Edad] <= 24 then "18-24"
else if [Edad] <= 34 then "25-34"
else if [Edad] <= 44 then "35-44"
else if [Edad] <= 54 then "45-54"
else "55+"
```
---


## 2. DAX Measures

A dedicated **Measures Table** was created in Power BI to store all key calculations.

### Measures included:

- `TotalIngresos := SUM(Transactions[TotalPrice])`
- `ClientesActivos := CALCULATE(DISTINCTCOUNT(Customers[CustomerID]), Customers[Estado] = "Activo")`
- `ChurnRate := DIVIDE(CALCULATE(DISTINCTCOUNT(Customers[CustomerID]), Customers[Estado] = "Inactivo"), DISTINCTCOUNT(Customers[CustomerID]))`
- `% of Churn`
- `Active customers`
- `avg_amount_per_purchase`
- `Churn target`
- `dif_product_purchased`
- `First Transaction Recorded`
- `Inactive customers`
- `Most Recent Transaction`
- `Total Rows Customers`
- `Total Transactions`
- `total_amount`

### Example of some DAX formulas:

```DAX
TotalRevenue := SUM(Transactions[TotalPrice])

ActiveCustomers := CALCULATE(
    DISTINCTCOUNT(Customers[CustomerID]), 
    Customers[Status] = "Active"
)

ChurnRate := DIVIDE(
    CALCULATE(DISTINCTCOUNT(Customers[CustomerID]), Customers[Status] = "Inactive"),
    DISTINCTCOUNT(Customers[CustomerID])
)
```
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

### Dashboard Conclusion

- Age range segmentation identifies priority customer groups.
- Measures Table in DAX provides all key metrics dynamically in one place.
- SQL views ensure data consistency and efficient calculations.
- The dashboard supports strategic retention and engagement decisions.

