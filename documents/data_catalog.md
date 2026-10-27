Data Catalog
1. Overview

This catalog describes the main analytical views in the Gold Layer of the SQL Server Data Warehouse.

The Gold Layer uses a Star Schema consisting of one sales fact view and two dimension views.

2. Customer Dimension

View: gold.dim_customers

Description: Contains customer information combined from CRM and ERP sources.

Column	Description
customer_key	Generated customer surrogate key
customer_id	Customer identifier from CRM
customer_number	Customer business key
first_name	Customer first name
last_name	Customer last name
country	Customer country
marital_status	Customer marital status
gender	Customer gender, using CRM as the primary source
birthdate	Customer birthdate from ERP
create_date	Customer record creation date
3. Product Dimension

View: gold.dim_products

Description: Contains current product information enriched with ERP category details.

Column	Description
product_key	Generated product surrogate key
product_id	Product identifier
product_number	Product business key
product_name	Product name
category_id	Product category identifier
category	Product category
subcategory	Product subcategory
maintenance	Product maintenance attribute
cost	Product cost
product_line	Product line classification
start_date	Product record start date

Only products with a NULL end date are included in this view.

4. Sales Fact View

View: gold.fact_sales

Description: Contains sales transactions linked to customer and product dimensions.

Column	Description
order_number	Sales order number
product_key	Product dimension surrogate key
customer_key	Customer dimension surrogate key
order_date	Sales order date
shipping_date	Shipping date
due_date	Due date
sales_amount	Sales amount recorded in the source
quantity	Quantity sold
price	Price recorded in the source
5. Relationships
fact_sales.customer_key links to dim_customers.customer_key.
fact_sales.product_key links to dim_products.product_key.

These relationships allow sales transactions to be analyzed using customer and product attributes.

6. Data Quality Notes
Surrogate keys are generated with ROW_NUMBER() in the dimension views.
Surrogate keys may change when the underlying data or row ordering changes.
The sales view uses LEFT JOIN, so unmatched customer or product keys can be NULL.
Source column types, nullability, and business definitions should be verified against the actual SQL Server schema.
