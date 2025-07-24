# E Commerce Data Analysis Using SQL and Tableau

### Project Objective and Overview

This project analyzes customer transactions from an online retailer, focusing on sales trends, customer behaviour, and order/return patterns. The goal was to uncover meaningful insights that can help inform marketing, logistics, and customer engagement strategies. In this project, Excel was used for data normalization, SQL for data analysis, and Tableau for visualizing the analysis.

[View the interactive dashboard on Tableau Public](https://public.tableau.com/app/profile/vansh.chandwaney/viz/ShopSmartUKRetail-Dashboard/SalesOverview)

### Description of the Dataset

The dataset was sourced from the [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/352/online+retail), containing over 500,000 transaction records from a UK-based retailer. The dataset is real but anonymized, and for this project, the retailer has been referred to as ShopSmart UK. 

The original dataset was long, with over 500,000 rows. Using Power Query on MS Excel, this dataset was normalized into a relational structure, with the four tables listed below. This preprocessing step was conducted so that the data model followed best practices before further analysis using SQL.

- **Invoice:**	Each unique transaction with a timestamp and status (delivered or cancelled)
- **Invoiceline:**	Line-level details for items purchased, including quantity and price
- **Product:**	Metadata including stockcode and product names
- **Customer:**	Customer IDs and their country of origin




