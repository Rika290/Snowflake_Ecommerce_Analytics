-- Step2. - Data Cleaning:-
create schema if not exists processed;

use ecommerce.processed;

--1. table customers
create or replace table processed.customers_clean as
select distinct 
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    initcap(trim(customer_city)) as customer_city,
    upper(trim(customer_state)) as customer_state
from raw.customers_raw
where customer_id is not null;

-- --2. table orders 
CREATE OR REPLACE TABLE processed.orders_clean AS
SELECT 
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    CASE 
        WHEN order_status IN ('canceled', 'unavailable') THEN 'Invalid'
        ELSE 'Valid'
    END AS order_flag
FROM raw.orders_raw
WHERE order_purchase_timestamp IS NOT NULL; 
--
-- 3.table  order_items 

CREATE OR REPLACE TABLE processed.order_items_clean AS
SELECT 
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    oi.shipping_limit_date,    
    CASE 
    WHEN oi.price IS NULL OR oi.freight_value IS NULL THEN 'Incomplete'
    WHEN oi.shipping_limit_date IS NULL THEN 'Missing_Shipping_Limit'
    WHEN o.order_delivered_customer_date > oi.shipping_limit_date THEN 'Late_Shipment'
    ELSE 'Valid'
END AS item_flag
FROM raw.order_items_raw oi
JOIN processed.orders_clean o 
    ON oi.order_id = o.order_id;
-- 
-- 4. table payments
CREATE OR REPLACE TABLE processed.payments_clean AS
SELECT p.order_id,
       p.payment_sequential, 
       initcap(trim(p.payment_type)) AS payment_type, 
       p.payment_installments,
       p.payment_value,
       CASE
           WHEN p.payment_value IS NULL OR p.payment_value <=0 THEN 'Invalid_Value'
           WHEN p.payment_type IS NULL THEN 'Missing_Type'
           WHEN p.payment_type NOT IN ('credit_card', 'boleto', 'voucher', 'debit_card') THEN 'Unknown_Type'
           ELSE 'Valid'
       END AS payment_flag    
FROM raw.payments_raw p 
JOIN processed.orders_clean o 
    ON p.order_id = o.order_id;
-- 5. table sellers 
CREATE OR REPLACE TABLE processed.sellers_clean AS 
SELECT distinct 
    seller_id,
    seller_zip_code_prefix,
    initcap(trim(seller_city)) as seller_city,
    upper(trim(seller_state))as seller_state
FROM raw.sellers;
-- 6. table products 
CREATE OR REPLACE TABLE processed.products_clean AS
SELECT 
    p.product_id,
    initcap(COALESCE(t.product_category_name_english, 'Unknown')) AS product_category
FROM raw.products p
LEFT JOIN raw.product_category_translation t 
    ON p.product_category_name = t.product_category_name; 

-- checking data in cleaned tables

select * from customers_clean;   -- table 1
select * from orders_clean;      -- table 2  
select * from order_items_clean; -- table 3  
select * from payments_clean;    -- table 4 
select * from products_clean;    -- table 5
select * from sellers_clean;     -- table 6
