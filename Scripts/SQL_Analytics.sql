-- Step 3- Analytics: 
use ecommerce;


use ecommerce.raw;
show tables;

select * from customers_raw;   -- table 1
select * from orders_raw;      -- table 2
select * from order_items_raw; -- table 3
select * from payments_raw;    -- table 4
select * from products;        -- table 5
select * from sellers;         -- table 6
--

create or replace schema analytics;

use ecommerce.processed;
show tables;

select * from customers_clean;   -- table 1
select * from orders_clean;      -- table 2 -- order_flag : Invalid, Valid
select * from order_items_clean; -- table 3 -- item_flag : Late_Shipment, Valid
select * from payments_clean;    -- table 4 -- payment_flag : Invalid_Value, Valid
select * from products_clean;    -- table 5
select * from sellers_clean;     -- table 6
-- 
use ecommerce.analytics;
show tables;
-- Step - Analytical / Aggregation Tables:-
--1. Top 10 Selling Categories
CREATE OR REPLACE TABLE analytics.top_10_selling_categories AS 
SELECT
    p.product_category,
    ROUND(SUM(oi.price),2) AS total_sales,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM processed.products_clean AS p 
JOIN processed.order_items_clean AS oi 
    ON p.product_id = oi.product_id
JOIN processed.orders_clean AS o
    ON oi.order_id = o.order_id
WHERE o.order_flag = 'Valid'
AND oi.item_flag = 'Valid'
GROUP BY 1  
ORDER BY total_sales DESC 
LIMIT 10;
--2. Monthly Sales Trend
CREATE OR REPLACE TABLE analytics.monthly_sales_trend AS
SELECT TO_CHAR(o.order_purchase_timestamp,'YYYY-MM') AS order_month,
       ROUND(SUM(oi.price),2) AS total_revenue,
       COUNT(DISTINCT oi.order_id) AS total_orders 
FROM processed.orders_clean AS o 
JOIN processed.order_items_clean AS oi 
ON o.order_id = oi.order_id
WHERE o.order_flag = 'Valid'
AND oi.item_flag = 'Valid'
GROUP BY 1 
ORDER BY order_month;
-- 3. Top 10 Cities by Revenue
CREATE OR REPLACE TABLE analytics.top_10_cities_by_revenue AS 
SELECT c.customer_city, 
       ROUND(SUM(oi.price),2) AS total_revenue,
       COUNT(DISTINCT o.order_id) AS total_orders
FROM processed.customers_clean AS c 
JOIN processed.orders_clean AS o
ON c.customer_id = o.customer_id 
JOIN processed.order_items_clean AS oi 
ON o.order_id = oi.order_id
WHERE o.order_flag = 'Valid'
AND oi.item_flag = 'Valid'
GROUP BY 1 
ORDER BY total_revenue DESC 
LIMIT 10;
--4. Most Preferred Payment Types
CREATE OR REPLACE TABLE analytics.preferred_payment_types AS 
SELECT p.payment_type,
       COUNT(DISTINCT o.order_id) AS total_orders,
       ROUND(SUM(p.payment_value),2) AS total_payment_value
FROM processed.payments_clean AS p 
JOIN processed.orders_clean AS o 
ON p.order_id=o.order_id
WHERE o.order_flag = 'Valid'
AND p.payment_flag ='Valid'
GROUP BY 1
ORDER BY total_orders DESC;
-- 5. top_10_sellers
CREATE OR REPLACE TABLE analytics.top_10_sellers AS 
SELECT s.seller_id,
       s.seller_city,
       ROUND(SUM(oi.price),2) AS total_sales,
       COUNT(DISTINCT oi.order_id) AS total_orders
FROM processed.sellers_clean AS s 
JOIN processed.order_items_clean AS oi 
  ON s.seller_id = oi.seller_id
JOIN processed.orders_clean AS o 
  ON o.order_id = oi.order_id
WHERE o.order_flag = 'Valid' 
AND oi.item_flag = 'Valid'
GROUP BY s.seller_id,s.seller_city
ORDER BY total_sales DESC 
LIMIT 10;
       
--
SELECT * FROM analytics.MONTHLY_SALES_TREND;
SELECT * FROM analytics.PREFERRED_PAYMENT_TYPES;
SELECT * FROM analytics.TOP_10_CITIES_BY_REVENUE;
SELECT * FROM analytics.TOP_10_SELLERS;
SELECT * FROM analytics.TOP_10_SELLING_CATEGORIES;
