# Phase 3: Exploratory Data Analysis (EDA)

In this phase, we conducted an in-depth exploratory analysis to better understand customer behavior, transaction patterns, and website interactions. All insights were stored in SQL CREATE VIEW statements to ensure reproducibility and easy consultation for further analysis.

## 1. Churn Status Overview
- The customer base consists of 49K users who never purchased, 27K inactive customers, and 23K active customers.
- Gender distribution is nearly identical across active and inactive groups, suggesting that gender does not influence churn.

## 2. Geographic Analysis
- Customer activity is highly concentrated in specific regions, particularly on the island of Jawa, with Jakarta Raya alone accounting for over 18% of active customers.
- This indicates that retention strategies should prioritize key geographic locations.

## 3. Customers at Risk of Leaving
- Customers with fewer than 3 total purchases or who have not purchased in over 90 days were identified as at-risk.
- Targeted retention campaigns should focus on this segment to reactivate former customers and reinforce loyalty among active users.

## 4. Monetary Value Segmentation
- Average spend per customer revealed top and low-spending groups.
- High-value customers should be prioritized for retention, while low-spending customers present opportunities for growth through targeted strategies.

## 5. Promotions and Churn
- Usage of promotions shows that nearly equal numbers of active and inactive customers use discounts.
- This suggests that promotions attract price-sensitive customers but do not necessarily foster long-term loyalty.
- Promotions can be better leveraged for acquiring new customers or reactivating inactive ones.

## 6. Payment Methods
- Credit Card remains the most popular method, with Gopay and OVO as strong alternatives.
- Reducing failed transactions is critical to improve overall payment success.

## 7. Website Behavior and Clickstream Analysis
- Inactive users frequently add items to the cart but abandon before completing the booking, whereas active users convert more successfully.
- On average, customers take 31 minutes from their first website event to make a purchase, highlighting the need to streamline the cart-to-booking process.
- Most products abandoned by inactive customers are the same as the top-selling products among active customers.

## 8. Product Insights
- Popular products, color trends, and seasonality were analyzed.
- Targeted re-engagement campaigns can focus on products most added to carts by inactive customers, using promotions to convert them into sales.

## Key Insights and Recommendations
- Customer inactivity is not influenced by gender but is geographically concentrated.
- Retention efforts should target at-risk customers and focus on critical touchpoints, especially the cart-to-booking stage.
- Promotions should be strategically applied rather than broadly, to attract specific segments or reactivate high-intent users.
- High-value customers require dedicated attention, while low-spending customers represent growth opportunities.
- Streamlining the purchase process and offering targeted incentives on desired products can significantly improve conversions and reduce churn.

## Overall Conclusion
The analysis reveals that the customer base is predominantly inactive or has never made a purchase, with only a small segment actively engaging with the platform. A significant portion of customers shows interest in products, frequently adding items to their cart, but often fails to complete transactions, indicating friction points in the purchase journey. While gender does not appear to influence churn, both geographic location and purchasing behavior are key determinants of customer activity. Additionally, while promotions and discounts generate short-term engagement, they do not necessarily foster long-term loyalty. These insights highlight opportunities to optimize the checkout process, implement targeted retention strategies, and strategically use promotions to convert interested customers into loyal buyers.
