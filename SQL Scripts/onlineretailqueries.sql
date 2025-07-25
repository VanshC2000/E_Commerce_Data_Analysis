-- ShopSmart UK | Sales, Customers and Returns Insights

USE onlineretail_10_11;

-- 1. What is the total sales revenue per month? 
SELECT 
    DATE_FORMAT(i.invoicedate, '%Y-%m') AS year_month_sort,
    SUM(il.quantity * il.price) AS total_revenue
FROM invoiceline il
JOIN invoice i
ON i.invoiceid = il.invoiceid
WHERE i.invoiceid NOT LIKE 'C%'  -- Exclude cancelled invoices
GROUP BY year_month_sort
ORDER BY year_month_sort;

-- 2. Which products generated the highest total revenue?
SELECT 
	il.stockcode, 
    p.productname,
    SUM(il.quantity * il.price) AS total_revenue
FROM invoiceline il
JOIN product p 
ON il.stockcode = p.stockcode
GROUP BY il.stockcode, p.productname
ORDER BY total_revenue DESC
LIMIT 10;
    
-- 3. Which countries contributed the most to revenue?
SELECT 	
	c.country, 
    SUM(il.quantity * il.price) AS total_revenue
FROM invoiceline il 
LEFT JOIN invoice i 
ON il.invoiceid = i.invoiceid
LEFT JOIN customer c ON i.customerid = c.customerid
WHERE i.invoiceid NOT LIKE 'C%'  -- excluding cancelled invoices
GROUP BY country
ORDER BY total_revenue DESC;

-- 4. Which customers have made the most purchases, by total value?
SELECT 
	c.customerid, 
    c.country, 
    SUM(il.quantity * il.price) AS total_spend
FROM invoiceline il 
JOIN invoice i 
ON il.invoiceid = i.invoiceid
JOIN customer c 
ON i.customerid = c.customerid
WHERE i.invoiceid NOT LIKE 'C%'  -- excluding cancelled invoices
GROUP BY c.customerid
ORDER BY total_spend DESC;

-- 5. Which customers placed the highest number of orders?
SELECT 
	c.customerid, 
	c.country, 
	COUNT(i.invoiceid) AS no_of_orders
FROM invoice i
JOIN customer c ON i.customerid = c.customerid
WHERE i.invoiceid NOT LIKE 'C%'  -- excluding cancelled invoices
GROUP BY c.customerid
ORDER BY no_of_orders DESC;

-- 6. What is the average order size (in quantity) per invoice?
WITH order_qty AS (
SELECT
	invoiceid, 
    SUM(quantity) AS total_order_qty
FROM invoiceline
GROUP BY invoiceid
)

SELECT
	AVG(total_order_qty) AS avg_order_qty
FROM order_qty;

-- 7. What is the average order size (in value) per invoice?
WITH order_value AS (
SELECT
	invoiceid, 
    SUM(price * quantity) AS total_order_value
FROM invoiceline
GROUP BY invoiceid
)

SELECT
	AVG(total_order_value) AS avg_order_value
FROM order_value;

-- 8. How many unique products were sold per month?
SELECT
  DATE_FORMAT(i.invoicedate, '%Y-%m') AS year_month_sort,
  COUNT(DISTINCT il.stockcode) AS unique_products_sold
FROM invoiceline il
JOIN invoice i ON il.invoiceid = i.invoiceid
WHERE i.invoiceid NOT LIKE 'C%'  -- Exclude cancelled invoices
GROUP BY year_month_sort
ORDER BY year_month_sort;

-- 9. What is the total % of cancelled invoices?
SELECT 
  ROUND((SELECT COUNT(invoiceid) 
   FROM invoice 
   WHERE invoiceid LIKE 'C%') * 100.0 / COUNT(invoiceid), 2) AS cancelledinvoicepercent
FROM invoice;

-- 10. What are the countries with the highest order cancellation rates?
SELECT
  c.country,
  COUNT(i.invoiceid) AS no_of_orders,
  ROUND(
    SUM(CASE WHEN i.invoiceid LIKE 'C%' THEN 1 ELSE 0 END) * 100.0 /
    COUNT(i.invoiceid), 
    2
  ) AS cancelled_invoice_rate
FROM customer c 
JOIN invoice i 
ON c.customerid = i.customerid
GROUP BY c.country
HAVING COUNT(i.invoiceid) > 10
ORDER BY cancelled_invoice_rate DESC;

-- 11. Which products had the highest return rates?
WITH product_summary AS (
SELECT
	il.stockcode,
	p.productname,
	SUM(CASE WHEN il.quantity > 0 THEN il.quantity ELSE 0 END) AS products_delivered,
	SUM(CASE WHEN il.quantity < 0 THEN ABS(il.quantity) ELSE 0 END) AS products_returned
FROM invoiceline il
JOIN invoice i ON il.invoiceid = i.invoiceid
JOIN product p ON il.stockcode = p.stockcode
GROUP BY il.stockcode, p.productname
)

SELECT
  stockcode,
  productname,
  products_delivered,
  products_returned,
  ROUND(
    products_returned * 1.0 / (products_delivered + products_returned)*100, 
    2
  ) AS return_rate
FROM product_summary
WHERE products_delivered > 10
ORDER BY return_rate DESC
LIMIT 20;

-- 12. How many repeat customers do we have?
SELECT
  COUNT(*) AS repeat_customers
FROM (
  SELECT customerid
  FROM invoice
  WHERE customerid IS NOT NULL AND invoiceid NOT LIKE 'C%'
  GROUP BY customerid
  HAVING COUNT(invoiceid) > 1
) AS repeat_customer_list;

-- 13. Percentage of repeat customers
SELECT
  ROUND(
    COUNT(*) * 100.0 / (
      SELECT COUNT(DISTINCT customerid)
      FROM invoice
      WHERE customerid IS NOT NULL AND invoiceid NOT LIKE 'C%'
    ),
    2
  ) AS repeat_customer_percentage
FROM (
  SELECT customerid
  FROM invoice
  WHERE customerid IS NOT NULL AND invoiceid NOT LIKE 'C%'
  GROUP BY customerid
  HAVING COUNT(invoiceid) > 1
) AS repeat_customer_list;
    
-- 14. What is the average time gap between purchases for each customer?
WITH no_of_orders AS ( 
	SELECT
		customerid, 
		COUNT(DISTINCT invoiceid) AS order_count
	FROM invoice
	WHERE invoiceid NOT LIKE 'C%' AND customerid IS NOT NULL
	GROUP BY customerid
)
SELECT 
  i.customerid,
  MIN(i.invoicedate) AS first_order_of_period,
  MAX(i.invoicedate) AS most_recent_order,
  ROUND(
    TIMESTAMPDIFF(DAY, MIN(i.invoicedate), MAX(i.invoicedate)) * 1.0 / (n.order_count - 1),
    2
  ) AS avg_days_between_orders
FROM invoice i
JOIN no_of_orders n ON i.customerid = n.customerid
WHERE i.invoiceid NOT LIKE 'C%' AND i.customerid IS NOT NULL
GROUP BY i.customerid, n.order_count
HAVING n.order_count > 1;

-- 15. RFM Analysis
WITH rfm_raw AS (
  SELECT
    i.customerid,
    MAX(i.invoicedate) AS most_recent_order,
    COUNT(DISTINCT i.invoiceid) AS frequency,
    SUM(il.quantity * il.price) AS monetary
  FROM invoice i
  JOIN invoiceline il ON i.invoiceid = il.invoiceid
  WHERE i.invoiceid NOT LIKE 'C%' AND i.customerid IS NOT NULL
  GROUP BY i.customerid
),
date_ref AS (
  SELECT MAX(invoicedate) AS last_date FROM invoice
)

SELECT
  r.customerid,
  DATEDIFF(d.last_date, r.most_recent_order) AS recency,
  r.frequency,
  ROUND(r.monetary, 2) AS monetary
FROM rfm_raw r
CROSS JOIN date_ref d;

-- 16. RFM with bins
WITH rfm_raw AS (
  SELECT
    i.customerid,
    MAX(i.invoicedate) AS most_recent_order,
    COUNT(DISTINCT i.invoiceid) AS frequency,
    SUM(il.quantity * il.price) AS monetary
  FROM invoice i
  JOIN invoiceline il ON i.invoiceid = il.invoiceid
  WHERE i.invoiceid NOT LIKE 'C%' AND i.customerid IS NOT NULL
  GROUP BY i.customerid
),
date_ref AS (
  SELECT MAX(invoicedate) AS last_date FROM invoice
),
rfm_base AS (
  SELECT
    r.customerid,
    DATEDIFF(d.last_date, r.most_recent_order) AS recency,
    r.frequency,
    ROUND(r.monetary, 2) AS monetary
  FROM rfm_raw r
  CROSS JOIN date_ref d
)

SELECT
  customerid,
  recency,
  frequency,
  monetary,

  -- Recency Bin
  CASE 
    WHEN recency <= 30 THEN 5
    WHEN recency <= 60 THEN 4
    WHEN recency <= 120 THEN 3
    WHEN recency <= 180 THEN 2
    ELSE 1
  END AS recency_score,

  -- Frequency Bin
  CASE 
    WHEN frequency >= 10 THEN 5
    WHEN frequency >= 6 THEN 4
    WHEN frequency >= 4 THEN 3
    WHEN frequency >= 2 THEN 2
    ELSE 1
  END AS frequency_score,

  -- Monetary Bin
  CASE 
    WHEN monetary >= 5000 THEN 5
    WHEN monetary >= 2001 THEN 4
    WHEN monetary >= 1001 THEN 3
    WHEN monetary >= 301 THEN 2
    ELSE 1
  END AS monetary_score

FROM rfm_base;

-- 17. What is the percentage of domestic orders (orders from the UK)?
SELECT 
  CASE 
    WHEN c.country = 'United Kingdom' THEN 'Domestic'
    ELSE 'International'
  END AS order_type,
  COUNT(*) AS num_orders
FROM invoice i 
JOIN customer c ON i.customerid = c.customerid
WHERE i.invoiceid NOT LIKE 'C%'
GROUP BY order_type;

-- 18. Total orders for the period (KPI)
SELECT 
	COUNT(invoiceid) AS no_of_orders
FROM invoice 
WHERE invoiceid NOT LIKE 'C%';

-- 19. Total Unique SKUs sold (KPI)
SELECT 
	COUNT(DISTINCT stockcode) AS uniqueskus
FROM invoiceline
WHERE quantity > 0;

-- 20. No. of customers who ordered during the period (KPI)
SELECT
	COUNT(DISTINCT customerid) AS no_of_customers
FROM invoice
WHERE customerid IS NOT NULL;

-- 21. Average customer spend
WITH customer_spend AS (
SELECT 
	c.customerid, 
    c.country, 
    SUM(il.quantity * il.price) AS total_spend
FROM invoiceline il 
JOIN invoice i 
ON il.invoiceid = i.invoiceid
JOIN customer c 
ON i.customerid = c.customerid
WHERE i.invoiceid NOT LIKE 'C%'  -- excluding cancelled invoices
GROUP BY c.customerid
ORDER BY total_spend DESC
)

SELECT
	ROUND(AVG(total_spend), 2) AS avgcustspend
FROM customer_spend;

-- 22. Return % by invoice value
WITH order_status AS (
  SELECT
    i.invoiceid,
    CASE 
      WHEN i.invoiceid LIKE 'C%' THEN 'Returned'
      ELSE 'Delivered'
    END AS invoice_status,
    SUM(ABS(il.quantity * il.price)) AS invoice_value
  FROM invoice i
  JOIN invoiceline il ON i.invoiceid = il.invoiceid
  GROUP BY i.invoiceid
),

bucketed_orders AS (
  SELECT
    invoiceid,
    invoice_status,
    invoice_value,
    CASE 
      WHEN invoice_value BETWEEN 0 AND 49.99 THEN '$0–$50'
      WHEN invoice_value BETWEEN 50 AND 99.99 THEN '$50–$100'
      WHEN invoice_value BETWEEN 100 AND 249.99 THEN '$100–$250'
      WHEN invoice_value BETWEEN 250 AND 499.99 THEN '$250–$500'
      WHEN invoice_value BETWEEN 500 AND 999.99 THEN '$500–$1000'
      WHEN invoice_value BETWEEN 1000 AND 2499.99 THEN '$1000–$2500'
      WHEN invoice_value BETWEEN 2500 AND 4999.99 THEN '$2500–$5000'
      WHEN invoice_value BETWEEN 5000 AND 9999.99 THEN '$5000–$10000'
      ELSE '$10000+'
    END AS order_value_bucket
  FROM order_status
)

SELECT
  order_value_bucket,
  COUNT(CASE WHEN invoice_status = 'Returned' THEN 1 END) AS cancelled_orders,
  COUNT(*) AS total_orders,
  ROUND(
    COUNT(CASE WHEN invoice_status = 'Returned' THEN 1 END) * 100.0 / COUNT(*),
    2
  ) AS order_cancellation_percentage
FROM bucketed_orders
GROUP BY order_value_bucket;

-- 23. Customers with the highest number of order cancellations
SELECT
	customerid, 
    SUM(CASE WHEN invoiceid LIKE 'C%' THEN 1 ELSE 0 END) AS order_cancellations,
    ROUND(SUM(CASE WHEN invoiceid LIKE 'C%' THEN 1 ELSE 0 END)/COUNT(*)*100, 2) AS order_cancellation_percentage
FROM invoice
WHERE customerid IS NOT NULL
GROUP BY customerid
HAVING order_cancellations > 1
ORDER BY order_cancellations DESC;
