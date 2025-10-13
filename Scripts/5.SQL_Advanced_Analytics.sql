use ecommerce.processed;
show tables;

select * from customers_clean;   -- table 1
select * from orders_clean;      -- table 2 -- order_flag : Invalid, Valid
select * from order_items_clean; -- table 3 -- item_flag : Late_Shipment, Valid
select * from payments_clean;    -- table 4 -- payment_flag : Invalid_Value, Valid
select * from products_clean;    -- table 5
select * from sellers_clean;     -- table 6
--
CREATE OR REPLACE SCHEMA ADVANCED_ANALYTICS;
USE ecommerce.advanced_analytics;

-- Creating views, stored procedure including window functions and CTEs.

-- 1. Customer order summary 
CREATE OR REPLACE VIEW advanced_analytics.vw_customer_order_summary AS 
SELECT c.customer_id, 
       c.customer_city,
       COUNT(DISTINCT o.order_id) AS total_orders,
       ROUND(SUM(p.payment_value),2) AS total_spent
FROM processed.customers_clean AS c
JOIN processed.orders_clean AS o
    ON c.customer_id = o.customer_id
JOIN processed.payments_clean AS p
    ON o.order_id = p.order_id
WHERE o.order_flag ='Valid' AND p.payment_flag = 'Valid'
GROUP BY c.customer_id,c.customer_city;

-- 2. Seller performance 
CREATE OR REPLACE VIEW advanced_analytics.vw_seller_performance AS   
SELECT s.seller_id,
       s.seller_city,
       COUNT(o.order_id) AS total_orders,
       ROUND(SUM(oi.price + oi.freight_value),2) AS total_sales,
       ROUND(AVG(oi.price),2) AS avg_order_value
FROM processed.orders_clean AS o 
JOIN processed.order_items_clean AS oi 
     ON o.order_id = oi.order_id 
JOIN processed.sellers_clean AS s
     ON oi.seller_id = s.seller_id
WHERE o.order_flag ='Valid' AND oi.item_flag = 'Valid'
GROUP BY s.seller_id, s.seller_city;

-- 3. Stored procedure for top 10 sellers 
CREATE OR REPLACE PROCEDURE advanced_analytics.refresh_analytics()
RETURNS STRING
LANGUAGE SQL
AS 
$$
BEGIN 
     CREATE OR REPLACE TABLE advanced_analytics.top_10_sellers AS 
     SELECT s.seller_id, s.seller_city,
            ROUND(SUM(oi.price),2) AS total_sales,
            COUNT(DISTINCT oi.order_id) AS total_orders
     FROM processed.order_items_clean AS oi 
     JOIN processed.sellers_clean AS s 
          ON s.seller_id = oi.seller_id 
     JOIN processed.orders_clean AS o 
          ON o.order_id = oi.order_id 
     WHERE o.order_flag = 'Valid' AND oi.item_flag = 'Valid'
     GROUP BY s.seller_id, s.seller_city
     ORDER BY total_sales DESC
     LIMIT 10;

     RETURN 'Analytics tables refreshed successfully!';
END;
$$;

CALL advanced_analytics.refresh_analytics();
SELECT * FROM advanced_analytics.top_10_sellers;

-- 4. Top 5 customers per city using CTE + Window Function
CREATE OR REPLACE VIEW advanced_analytics.vw_top_customers_per_city AS
WITH customer_spending AS(
SELECT c.customer_id,
       c.customer_city,
       ROUND(SUM(p.payment_value),2) AS total_spent
FROM processed.customers_clean AS c
JOIN processed.orders_clean AS o
     ON c.customer_id = o.customer_id
JOIN processed.payments_clean AS p
     ON o.order_id = p.order_id
WHERE o.order_flag ='Valid' AND p.payment_flag = 'Valid'
GROUP BY c.customer_id,c.customer_city
)
SELECT customer_id,
       customer_city,
       total_spent,
       RANK() OVER(PARTITION BY customer_city ORDER BY total_spent DESC) AS spending_rank
FROM customer_spending
QUALIFY spending_rank <=5;

-- 5. Average delivery delay
CREATE OR REPLACE VIEW advanced_analytics.vw_seller_avg_delivery_delay AS
WITH delivery_delay AS (
SELECT s.seller_id,
       s.seller_city,
       DATEDIFF('day', o.order_delivered_customer_date, o.order_estimated_delivery_date) AS delay_days
FROM processed.sellers_clean AS s
JOIN processed.order_items_clean AS oi 
    ON s.seller_id = oi.seller_id
JOIN processed.orders_clean AS o 
    ON oi.order_id = o.order_id
WHERE o.order_flag = 'Valid'
AND o.order_delivered_customer_date IS NOT NULL
)
SELECT seller_id,
       seller_city,
       ROUND(AVG(delay_days),2) AS avg_delay
FROM delivery_delay 
GROUP BY seller_id, seller_city
ORDER BY avg_delay DESC;

-- 6. Cumulative sales per seller
CREATE OR REPLACE VIEW advanced_analytics.vw_cumulative_sales AS 
SELECT s.seller_id,
       s.seller_city,
       SUM(oi.price+oi.freight_value) OVER(PARTITION BY s.seller_id ORDER BY o.order_purchase_timestamp) AS cumulative_sales
FROM processed.sellers_clean AS s 
JOIN processed.order_items_clean AS oi 
    ON s.seller_id = oi.seller_id
JOIN processed.orders_clean AS o 
    ON oi.order_id = o.order_id
WHERE o.order_flag = 'Valid' AND oi.item_flag = 'Valid';

-- 7. Percentile Ranking of Customers by Spending
CREATE OR REPLACE VIEW advanced_analytics.vw_customer_percentile AS 
WITH customer_spending AS (
     SELECT c.customer_id,
            ROUND(SUM(p.payment_value),2) AS total_spent
     FROM processed.customers_clean AS c
     JOIN processed.orders_clean AS o
          ON c.customer_id = o.customer_id
    JOIN processed.payments_clean AS p
          ON o.order_id = p.order_id
    WHERE o.order_flag = 'Valid' AND p.payment_flag = 'Valid'
    GROUP BY c.customer_id)
SELECT customer_id,
       total_spent,
       PERCENT_RANK() OVER(ORDER BY total_spent DESC) AS spending_percentile
FROM customer_spending;

-- 8. Rank product categories by sales per month
WITH sales_category AS (
      SELECT MONTHNAME(o.order_purchase_timestamp) AS Month,
            p.product_category,
            SUM(oi.price) AS total_sales
      FROM processed.orders_clean AS o 
      JOIN processed.order_items_clean AS oi
          ON o.order_id = oi.order_id 
      JOIN processed.products_clean AS p
          ON p.product_id = oi.product_id
      GROUP BY Month, p.product_category
) 
SELECT Month,
       product_category,
       RANK() OVER(PARTITION BY MONTH ORDER BY total_sales DESC) AS category_rank
FROM sales_category
ORDER BY Month, category_rank;

-- 9. KPI summary
CREATE OR REPLACE VIEW advanced_analytics.vw_kpi_summary AS
SELECT 
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS total_customers,
    ROUND(SUM(p.payment_value),2) AS total_revenue,
    ROUND(AVG(p.payment_value),2) AS avg_order_value,
    ROUND(AVG(DATEDIFF('day', o.order_purchase_timestamp, o.order_delivered_customer_date)),2) AS avg_delivery_days
FROM processed.orders_clean o
JOIN processed.customers_clean c ON o.customer_id = c.customer_id
JOIN processed.payments_clean p ON o.order_id = p.order_id
WHERE o.order_flag = 'Valid' AND p.payment_flag = 'Valid';

-- 10. Optmizations:
-- 10)a.Table-level optimization → Clustering by order_month
USE ecommerce.analytics;
SELECT * 
FROM analytics.monthly_sales_trend
WHERE order_month BETWEEN '2017-01' AND '2022-03'; -- 85,86 ms
--
-- Optimize query performance by clustering on the date column
ALTER TABLE analytics.monthly_sales_trend 
CLUSTER BY (order_month);
--10)b. Query-level optimization using filter pushdown on "vw_customer_order_summary"
CREATE OR REPLACE VIEW advanced_analytics.vw_customer_order_summary_optimized AS 
WITH valid_orders AS (
    SELECT order_id, customer_id
    FROM processed.orders_clean
    WHERE order_flag = 'Valid'
),
valid_payments AS (
    SELECT order_id, payment_value
    FROM processed.payments_clean
    WHERE payment_flag = 'Valid'
)
SELECT c.customer_id, 
       c.customer_city,
       COUNT(DISTINCT o.order_id) AS total_orders,
       ROUND(SUM(p.payment_value),2) AS total_spent
FROM processed.customers_clean AS c
JOIN valid_orders AS o
    ON c.customer_id = o.customer_id
JOIN valid_payments AS p
    ON o.order_id = p.order_id
GROUP BY c.customer_id, c.customer_city;

