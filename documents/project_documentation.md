End-to-End SQL Data Warehouse & Analytics Project
1. Project Overview

This project demonstrates the design and implementation of an end-to-end SQL Server Data Warehouse using data from two source systems: CRM (Customer Relationship Management) and ERP (Enterprise Resource Planning).

The goal is to integrate data from multiple sources, clean and transform it, and organize it into a business-ready format for reporting, analytics, and business intelligence.

The project follows the Medallion Architecture, which consists of three layers:

Bronze Layer: Stores raw data from source systems.
Silver Layer: Cleans, standardizes, and transforms raw data.
Gold Layer: Provides business-ready views for reporting and analysis.

The final data model uses a Star Schema to support analytical queries and business intelligence reporting.

2. Project Objectives
Build an end-to-end data warehouse using SQL Server.
Integrate data from CRM and ERP source systems.
Develop ETL processes to load and transform data.
Clean and standardize data for consistency and accuracy.
Create customer and product dimensions and a sales fact view.
Implement data quality checks to validate the warehouse.
Prepare business-ready data for BI dashboards, reporting, and ad-hoc SQL queries.
Organize SQL scripts and documentation using Git and GitHub.
3. Data Architecture

The data flows through the following stages:

CRM and ERP Sources → Bronze Layer → Silver Layer → Gold Layer → Reporting and Analytics

The architecture separates raw data storage, data transformation, and business-level presentation to make the warehouse easier to maintain and understand.

Architecture Components
Component	Description
Source Systems	CRM and ERP data provided as CSV files.
Bronze Layer	Stores raw source data in SQL Server tables.
Silver Layer	Cleans, standardizes, and enriches the data.
Gold Layer	Contains business-ready SQL views.
BI & Reporting	Supports dashboards and business reports.
Ad-hoc SQL Queries	Allows users to explore data directly.
Machine Learning	Represents a potential future use for prepared analytical data.
4. Data Sources

The project uses two primary source systems.

CRM (Customer Relationship Management)

CRM provides customer, product, and sales information.

Examples include:

Customer details
Product information
Sales transactions
ERP (Enterprise Resource Planning)

ERP provides additional customer and product-related information.

Examples include:

Customer birthdates and gender
Customer location and country
Product categories and subcategories

Combining these sources creates a more complete view of customers, products, and sales.

5. Data Warehouse Layers
5.1 Bronze Layer

The Bronze Layer is the first stage of the data warehouse.

Purpose: Store raw data from source files with minimal transformation.

Key characteristics:

Data is loaded from CSV files.
Raw source values are preserved.
Data is stored in SQL Server tables.
Stored procedures handle data loading.
Batch processing and full-load operations are supported.

This layer provides the original data used by subsequent transformation steps.

5.2 Silver Layer

The Silver Layer improves the quality and consistency of raw data.

Purpose: Clean, standardize, and integrate data from the Bronze Layer.

Key transformations include:

Data cleansing
Data standardization
Data normalization
Creation of derived columns
Data enrichment
Integration of related source data

Stored procedures are used to process and load data into the Silver Layer.

The resulting tables provide a consistent foundation for building the Gold Layer.

5.3 Gold Layer

The Gold Layer contains business-ready data for reporting and analysis.

Purpose: Present clean, integrated data in a format that is easy to query.

This project uses SQL views to create the final analytical model.

The Gold Layer includes:

gold.dim_customers — customer dimension
gold.dim_products — product dimension
gold.fact_sales — sales fact view

These views combine information from the Silver Layer and organize it into a Star Schema.

Unlike the Bronze and Silver Layers, the Gold Layer uses views rather than storing another physical copy of the transformed data.

6. Data Model: Star Schema

The Gold Layer uses a Star Schema consisting of one sales fact view and two dimension views.

Fact View: gold.fact_sales

Contains sales transactions and measures used for analysis.

Key columns:

order_number
product_key
customer_key
order_date
shipping_date
due_date
sales_amount
quantity
price
Dimension View: gold.dim_customers

Contains descriptive information about customers.

Key columns:

customer_key
customer_id
customer_number
first_name
last_name
country
marital_status
gender
birthdate
create_date
Dimension View: gold.dim_products

Contains descriptive information about current products.

Key columns:

product_key
product_id
product_number
product_name
category_id
category
subcategory
maintenance
cost
product_line
start_date
Relationships

The sales fact view connects to the dimension views through their surrogate keys:

fact_sales.customer_key → dim_customers.customer_key
fact_sales.product_key → dim_products.product_key

These relationships allow sales data to be analyzed by customer, product, country, category, and date.

7. Data Transformation Rules
Customer Dimension
CRM is the primary source for customer information.
ERP data supplements customer information.
CRM gender is preferred when it is available and is not 'n/a'.
ERP gender is used as a fallback.
If neither source provides a usable gender value, 'n/a' is returned.
Customer surrogate keys are generated using ROW_NUMBER().
Product Dimension
Product details are obtained from CRM.
Category and subcategory information is obtained from ERP.
Only current products are included.
Historical product records are excluded using WHERE prd_end_dt IS NULL.
Product surrogate keys are generated using ROW_NUMBER().
Sales Fact View
Sales transactions are obtained from CRM.
Product surrogate keys are retrieved by matching product numbers.
Customer surrogate keys are retrieved by matching customer IDs.
Order, shipping, and due dates are retained.
Sales amount, quantity, and price are exposed as analytical measures.
LEFT JOIN operations preserve sales records even when a matching dimension record is missing.
8. Data Quality Checks

Data quality checks validate the Gold Layer and help identify potential problems.

Customer Key Uniqueness

Checks whether customer surrogate keys are duplicated in gold.dim_customers.

Expected result: No rows returned.

Product Key Uniqueness

Checks whether product surrogate keys are duplicated in gold.dim_products.

Expected result: No rows returned.

Fact-to-Dimension Relationships

Checks whether sales records have matching customers and products in the dimension views.

Expected result: No rows returned when all sales records have valid dimension matches.

If records are returned, the missing relationships should be investigated.

These checks help identify issues that could affect reporting accuracy.

9. Reporting and Analytics

The Gold Layer can support several analytical use cases, including:

Total sales analysis
Sales quantity analysis
Sales by customer
Sales by product
Sales by product category
Sales by country
Order date and shipping date analysis
Customer and product reporting

The business-ready views can be queried directly using SQL or connected to a business intelligence tool such as Power BI.

10. Technologies Used
Microsoft SQL Server: Database platform and data warehouse.
T-SQL: SQL queries, views, and stored procedures.
CSV Files: Source data format.
Git and GitHub: Source control and project documentation.
Power BI or other BI tools: Potential reporting and visualization tools.
11. Project Folder Structure

The repository is organized into folders for setup, datasets, documentation, SQL scripts, and testing.


12. Conclusion

The End-to-End SQL Data Warehouse & Analytics Project demonstrates how to build a SQL Server Data Warehouse that integrates CRM and ERP data into a structured analytical environment.

Using the Bronze, Silver, and Gold architecture separates data ingestion, data cleansing, and business-level presentation. The Star Schema makes the final data easier to query, while data quality checks help identify duplicate keys and missing relationships.

The project provides a foundation for business intelligence, reporting, and further data analysis.

13. Future Improvements

Potential improvements include:

Automating ETL execution and scheduling.
Adding incremental data loading.
Implementing persistent surrogate keys.
Expanding data quality checks.
Adding more dimensions and fact views.
Connecting the Gold Layer to Power BI.
Developing dashboards and KPIs.
Improving ETL logging and error handling.
