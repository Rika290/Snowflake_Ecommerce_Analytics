-- Data link: Brazilian E-Commerce Public Dataset by Olist - https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce?resource=download&select=olist_products_dataset.csv

--Step 1- Raw Schema
create DATABASE ecommerce;

use DATABASE ecommerce;

create SCHEMA raw;

use SCHEMA raw;

create STAGE raw_stage;

use ecommerce.raw;

show tables in ecommerce.raw;

CREATE TABLE customers_raw (
    customer_id STRING,
    customer_unique_id STRING,
    customer_zip_code_prefix STRING,
    customer_city STRING,
    customer_state STRING
);

CREATE TABLE orders_raw (
    order_id STRING,
    customer_id STRING,
    order_status STRING,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE order_items_raw (
    order_id STRING,
    order_item_id NUMBER,
    product_id STRING,
    seller_id STRING,
    shipping_limit_date TIMESTAMP,
    price FLOAT,
    freight_value FLOAT
);

CREATE TABLE payments_raw (
    order_id STRING,
    payment_sequential NUMBER,
    payment_type STRING,
    payment_installments NUMBER,
    payment_value FLOAT
);

-- Step 2: Load Stage → RAW Tables
LIST @raw_stage;

COPY INTO raw.customers_raw
FROM @raw_stage/olist_customers_dataset.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER=1);

COPY INTO raw.orders_raw
FROM @raw_stage/olist_orders_dataset.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER=1);

COPY INTO raw.order_items_raw
FROM @raw_stage/olist_order_items_dataset.csv
FILE_FORMAT = (TYPE = 'CSV'
FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER=1);

COPY INTO raw.payments_raw
FROM @raw_stage/olist_order_payments_dataset.csv
FILE_FORMAT = (TYPE = 'CSV'
FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER=1);

-- data loaded into table from local
CREATE TABLE sellers(
    seller_id string,
    seller_zip_code_prefix NUMBER,
    seller_city STRING,
    seller_state STRING
);

CREATE TABLE products(
product_id string,
product_category_name STRING,
product_name_lenght NUMBER,
product_description_lenght NUMBER,
product_photos_qty NUMBER,
product_weight_g NUMBER,
product_length_cm NUMBER,
product_height_cm NUMBER,
product_width_cm NUMBER);

CREATE TABLE product_category_translation(
product_category_name STRING,
product_category_name_english STRING); 

select * from products;
-- dropping columns 
alter table products
drop column product_name_lenght, product_description_lenght, product_photos_qty, product_weight_g, product_length_cm,product_height_cm,product_width_cm;

select  count(distinct product_category_name) from products;
select * from product_category_translation;

select count(distinct product_category_name_english) from product_category_translation; -- 72
--
select  count(distinct product_category_name) from products; -- 73 
select product_category_name,count(*) 
from products group by 1
order by product_category_name desc;
--

-- checking data in all tables
select * from customers_raw;   -- table 1
select * from orders_raw;      -- table 2
select * from order_items_raw; -- table 3
select * from payments_raw;    -- table 4
select * from sellers;         -- table 5
select * from products_clean;  -- table 6

