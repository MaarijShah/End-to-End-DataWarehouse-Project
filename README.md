End-to-End SQL Data Warehouse & Analytics Project

Building a data warehouse with SQL Server | Data Engineering | ETL | Dimensional Modeling

📌 Overview

This project demonstrates the development of a SQL Server data warehouse that integrates CRM and ERP data into a centralized environment for analytics and reporting.

The project follows a Medallion Architecture (Bronze, Silver, and Gold) to organize data ingestion, transformation, and presentation. The final Gold Layer uses a Star Schema to make customer, product, and sales data easier to analyze.

🎯 Key Features
Data Integration: Combines data from CRM and ERP source systems.
ETL Development: Loads, cleans, and transforms data using SQL Server and T-SQL.
Medallion Architecture: Separates raw, transformed, and business-ready data.
Dimensional Modeling: Organizes analytical data using a Star Schema.
Data Quality Validation: Checks surrogate key uniqueness and fact-to-dimension relationships.
SQL Analytics: Prepares sales data for business intelligence and reporting.
🏗️ Architecture

The project follows this data pipeline:

text
       CRM and ERP Sources
                |
                v
         Bronze Layer
           Raw Data
                |
                v
         Silver Layer
   Cleaned and Transformed Data
                |
                v
          Gold Layer
      Business-Ready Views
                |
                v
       Analytics & Reporting

⭐ Gold Layer Data Model

The analytical model consists of three SQL views:

View	Purpose
gold.dim_customers	Provides customer information for analysis.
gold.dim_products	Provides product and category information.
gold.fact_sales	Contains sales transactions and measures.

The sales fact view connects to the customer and product dimensions through surrogate keys, supporting analysis across customers, products, categories, countries, and dates.

🛠️ Tech Stack
Microsoft SQL Server
T-SQL
SQL Server Management Studio (SSMS)
CSV source files
Git and GitHub
📂 Repository Structure
text
sql-data-warehouse-project/
├── 00_setup/       # Database setup
├── 01_datasets/    # CRM and ERP source data
├── 02_docs/        # Project documentation and diagrams
├── 03_scripts/     # SQL scripts for ETL and data modeling
├── 04_tests/       # Data quality checks
└── README.md       # Project overview

🚀 Getting Started
Clone or download this repository.
Open SQL Server Management Studio and connect to your SQL Server instance.
Review the database setup scripts and configure the required database.
Load the CRM and ERP source data into the Bronze Layer.
Run the transformation scripts for the Silver Layer.
Create the Gold Layer views.
Execute the data quality checks and explore the results.

Review the SQL scripts and update file paths or database settings as needed for your environment.

📖 Documentation

For the complete technical explanation, including data transformations, Star Schema design, column descriptions, and data quality checks, see the Project Documentation.

👨‍💻 Author

Maarij Shah

GitHub: @MaarijShah

This project is based on a guided data engineering tutorial and is being developed for hands-on learning and portfolio building.
