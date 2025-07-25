# E Commerce Data Analysis Using SQL and Tableau

### Project Objective and Overview

This project analyzes customer transactions from an online retailer, focusing on sales trends, customer behaviour, and order/return patterns. The goal was to uncover meaningful insights that can help inform marketing, logistics, and customer engagement strategies. In this project, Excel was used for data normalization, SQL for data analysis, and Tableau for visualizing the analysis.

[View the interactive dashboard on Tableau Public](https://public.tableau.com/app/profile/vansh.chandwaney/viz/ShopSmartUKRetail-Dashboard/SalesOverview)

---
### Description of the Dataset

The dataset was sourced from the [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/352/online+retail), containing over 500,000 transaction records from a UK-based retailer. The dataset is real but anonymized, and for this project, the retailer has been referred to as ShopSmart UK. 

The original dataset was long, with over 500,000 rows. Using Power Query on MS Excel, this dataset was transformed and normalized into a relational structure, with the four tables listed below.

- **Invoice:**	Each unique transaction with a timestamp and status (delivered or cancelled)
- **Invoiceline:**	Line-level details for items purchased, including quantity and price
- **Product:**	Metadata including stockcode and product names
- **Customer:**	Customer IDs and their country of origin

This preprocessing step was conducted so that the data model followed best practices before further analysis using SQL. 

#### Data cleaning summary
The dataset was largely clean and well-structured, but there were a few inconsistencies present, and these were treated as follows:
- Product Names such as "???" or "Given away" were removed due to ambiguity.
- Invoice IDs that did not follow the expected format (either 5-digit numbers or prefixed by "C" to indicate cancellation) were excluded to maintain data integrity.
- Records with country = 'Unspecified' were updated to NULL using SQL to improve data consistency, and so that "Unspecified" does not show up as a country name.
- The values in the invoicedate column did not align with the standard SQL `DATETIME` format, so the column was reformatted.

---
### Key findings
**1. Revenue Growth**
- **Strong Revenue Acceleration:** Sales revenue nearly tripled from Q2 2011 lows ($509K) to a November 2011 peak of $1.46M. This indicates solid business momentum and seasonal demand patterns.

**2. Customer Segmentation**
- **High-Value Loyal Customer Base:** An average spend of $2,021 per customer and a 65.26% repeat order rate demonstrate the strong relationships ShopSmart UK has with its wholesale partners, who place frequent and sizable orders
- **Bi-Weekly to Monthly Purchase Patterns:** Many customers purchase in cycles of 14–30 days. This indicates an opportunity to schedule tailored marketing campaigns and inventory decisions around predictable wholesaler behaviour.
- **Inactive Customer Reactivation Potential:** A segment of 622 customers with low recency and frequency scores was identified. These customers need to be reengaged before they churn.
- **Top Customer Revenue Dependence:** The top 10 customers contribute over $1.6M in revenue, with one customer alone spending $279K. The company needs to diversify its customer base to reduce risks.
- 
**3. Operational Inefficiencies**
- **Significant Order Cancellations:** A 13.53% overall cancellation rate signals operational inefficiencies, with some individual customers canceling over 40% of orders—highlighting the need for tighter policies and fraud mitigation.
- **Regional Cancellation Disparities:** Countries like Italy and Switzerland show high cancellation rates despite strong revenue contributions, indicating regional logistical or product-market fit issues requiring optimization.
- **Severe Quality Concerns in Travel Category:** Travel accessories, particularly Travel Card Wallets, show return rates exceeding 80–94%. This poses a major risk in bulk sales, where poor product quality can amplify losses and damage wholesale client trust.

**5. Growth Opportunities**
- **Party-Themed Product Dominance:** The top 3 revenue-generating products are all party-themed, suggesting a strong product-market fit that should be leveraged through increased inventory and promotional focus.
- **Untapped International Premium Segment:** While international orders make up only 9.31% of volume, they represent significantly higher spend per customer—indicating potential for expansion through tailored international strategies.







