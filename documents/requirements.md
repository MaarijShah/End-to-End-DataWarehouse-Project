Project Requirements
1. Project Overview

The objective of this project is to build an end-to-end SQL Server data warehouse that integrates CRM and ERP data for reporting and analytics.

The warehouse uses a Bronze, Silver, and Gold architecture to organize data ingestion, transformation, and business-ready presentation.

2. Business Requirements
Consolidate customer, product, and sales information from CRM and ERP sources.
Improve data consistency and reliability.
Provide a centralized source for sales analysis.
Enable analysis by customer, product, category, country, and date.
Support future business intelligence reporting.
3. Functional Requirements
Data Ingestion
Load CRM and ERP source data from CSV files.
Store raw data in the Bronze Layer.
Data Transformation
Clean and standardize data in the Silver Layer.
Integrate related customer and product information.
Apply business rules to produce consistent data.
Data Modeling
Create a customer dimension view.
Create a product dimension view.
Create a sales fact view.
Connect sales transactions to customer and product dimensions.
Data Quality
Check customer surrogate key uniqueness.
Check product surrogate key uniqueness.
Identify sales records without matching customer or product dimensions.
4. Technical Requirements
Microsoft SQL Server
T-SQL
SQL Server Management Studio (SSMS)
CRM and ERP CSV datasets
Git and GitHub for version control and documentation
5. Gold Layer Objects
Object	Purpose
gold.dim_customers	Customer information
gold.dim_products	Current product information
gold.fact_sales	Sales transactions and measures
6. Expected Outcomes
An organized SQL Server data warehouse.
Cleaned and integrated data across the warehouse layers.
A Star Schema for analytical queries.
SQL-based data quality checks.
Documentation supporting maintenance and future development.
7. Scope and Limitations

This project focuses on SQL Server data warehousing and SQL-based analytics. Automated scheduling, Power BI dashboards, and incremental loading are potential future enhancements rather than assumed completed features.
