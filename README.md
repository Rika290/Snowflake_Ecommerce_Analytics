# 🧊 Snowflake_Ecommerce_Analytics

## 📌 Project Overview:
- End-to-end data analytics pipeline built entirely in Snowflake, transforming raw e-commerce data into business-ready insights using SQL.
- The project demonstrates layered architecture, data quality validation, advanced SQL analytics, and query optimization techniques (CTEs, window functions, clustering).
- 📊 Dataset Source: [Click here to view on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce?resource=download&select=olist_products_dataset.csv)

### 🧰 Tech Stack:

- Snowflake – Cloud data warehouse for storage, transformation, and analytics
- SQL – Data modeling, transformations, and advanced analytics
- Stored Procedures & Views – Automated table refresh and complex query management
- Data Quality Checks – Ensuring data consistency and integrity

### 🏗️ Architecture Diagram:
![Architecture Diagram](images/architecture_diagram.jpg)

📘 The diagram illustrates the end-to-end flow:
from raw CSV ingestion → data cleaning and transformation → analytical aggregation → advanced analytics, all within Snowflake.

### 📸 Snapshots:
📊 Data Warehouse Design and Snowflake Schema:
 - Developed a Snowflake-based data warehouse to efficiently organize and analyze e-commerce sales data.
 - Designed a Snowflake schema model optimized for analytical queries, enabling seamless exploration of customer behavior, order patterns, and revenue insights.
 - The data model comprises fact tables capturing transactional metrics and dimension tables providing descriptive business context.

Schema Highlights:
 - Fact Tables: FactOrders, Order_ItemsFact, and PaymentsFact — contain order, item-level, and payment transaction data.
 - Dimension Tables: DimCustomer, DimProduct, and DimSeller — store customer, product, and seller details.
 - Relationships are defined through primary–foreign key mappings (customer_id, product_id, seller_id, order_id) for consistent referential integrity.
   
📘 Below is the data model used for this project:
![Data Model](images/data_model.jpg)

Here’s a snapshot of the data table from the project:

![Dataset Preview](images/tables_overview.jpg)

### 🔄 Pipeline Overview:
1️⃣ Raw Layer – Data Ingestion:
- Loaded CSV files into Snowflake using the COPY INTO command
- Stored in schema: ecommerce.raw
- Created base raw tables for:
  1.customers_raw
  2.orders_raw
  3.order_items_raw
  4.payments_raw
  5.products
  6.sellers

2️⃣ Processed Layer – Data Cleaning & Transformation:
- Stored in schema: ecommerce.processed
- key steps performed in Cleaning & Processing:
  1. Trimming spaces, standardizing data types, handling nulls
  2. Validation flags: order_flag, item_flag, payment_flag
  3. Deduplication, inconsistent entries removed
- Cleaned Tables:
   - customers_clean
   - orders_clean
   - order_items_clean
   - payments_clean
   - products_clean
   - sellers_clean

3️⃣ Analytics Layer – Business Aggregations:
- Stored in schema: ecommerce.analytics
- Generated key aggregated insights for decision-making:
  
|           🧩  Insight            |                     📄 Description                   |
|-----------------------------------|------------------------------------------------------|
|     `Top 10 Cities by Revenue`    |     Cities contributing the most to total revenue    |
|     `Preferred Payment Types`     |     Most used and highest-value payment methods      |
|     `Top 10 Selling Categories`   |     Product categories with highest total sales      |
|     `Top 10 Sellers`              |     Sellers generating the highest sales             |
|     `Monthly Sales Trend`         |     Month-wise revenue and order volume trend        |


4️⃣ Advanced Analytics Layer – Deep Insights:
- Stored in schema: ecommerce.advanced_analytics
- Implemented advanced SQL topics such as:
  - CTEs for modular query optimization
  - Window functions (RANK(), SUM() OVER()) for ranking and cumulative metrics
  - Views for reusable analytical logic
  - Stored Procedures for automated refresh of top-performing tables
  - Examples:
      - vw_customer_order_summary
      - vw_top_customers_per_city
      - sp_refresh_top_sellers

### ⚙️ Optimizations Implemented

|       Type      |                    📄 Description                                              |                            Example                                 |
|-----------------|--------------------------------------------------------------------------------|---------------------------------------------------------------------|
|  `Query-Level`  |  Pushed filters early using CTEs to reduce scanned data                        | vw_customer_order_summary_optimized                                 |
|  `Table-Level`  |  Clustered tables on high-frequency filter columns to improve scan performance | ALTER TABLE analytics.monthly_sales_trend CLUSTER BY (order_month); |

- ✅ Result: Faster query execution and reduced Snowflake compute cost.

### 📊 Business Insights Generated
- 📈 Monthly growth in sales and revenue
- 🏙️ Highest revenue-contributing cities
- 💳 Customer payment behavior and preferences
- 👥 Top customers per city (window functions)
- 📦 Top sellers by performance and revenue share

## 🧾 Project Summary by Layer

| Layer | Schema | Key Tables / Objects | Purpose |
|-------|--------|----------------------|----------|
| **Raw** | `ecommerce.raw` | customers_raw, orders_raw, order_items_raw, payments_raw | Data ingestion from CSV using COPY INTO |
| **Processed** | `ecommerce.processed` | customers_clean, orders_clean, payments_clean | Data cleaning, validation flags, deduplication |
| **Analytics** | `ecommerce.analytics` | monthly_sales_trend, top_10_cities_by_revenue | Aggregated business-level insights |
| **Advanced Analytics** | `ecommerce.advanced_analytics` | vw_top_customers_per_city, sp_refresh_top_sellers | Deep analytics using CTEs, window functions, clustering |

## 📂 Project Structure: 
- `README.md` → Complete project documentation
- `1_SQL_Raw.sql` → Create and load raw tables
- `2_SQL_Cleaning_and_Processing.sql` → Data cleaning and flagging
- `3_SQL_Analytics.sql` → Business-level aggregated tables
- `4_SQL_Quality_Check.sql` → Data quality validation
- `5_SQL_Advanced_Analytics.sql` → Advanced analytics (CTEs, window, optimization)
- `images/` →
  - `architecture_diagram.jpg` → End-to-end Snowflake data pipeline architecture
  - `data_model.jpg` → Snowflake schema / dimensional model
  - `tables_overview.jpg` → Snapshot of Snowflake tables
  
### 🧠 Key Learnings:
- Designed a multi-layered Snowflake architecture using best practices  
- Implemented data quality validation and referential integrity  
- Optimized SQL queries using CTEs and clustering for performance  
- Automated analytics refresh with stored procedures and views  

