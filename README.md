# Building a Data Warehouse | Data Engineering & Analytics

## 📌 Project Overview

This project focuses on building a modern data warehouse using **Microsoft SQL Server** to consolidate sales data from two source systems: **ERP (Enterprise Resource Planning)** and **CRM (Customer Relationship Management)**.

The project demonstrates an end-to-end data engineering workflow, including data extraction, transformation, data quality management, data integration, dimensional modeling, and SQL-based analytics.

The goal is to transform raw business data into a clean, consistent, and reliable data model that supports business intelligence and data-driven decision-making.

## 🎯 Project Objectives

- Integrate data from ERP and CRM source systems using CSV files.
- Clean and standardize data by resolving data quality issues.
- Transform raw data into a structured and user-friendly data warehouse.
- Design a data model optimized for analytical queries.
- Develop SQL queries to analyze customer behavior, product performance, and sales trends.
- Document the data model to support business stakeholders and analytics teams.

## 🏗️ Data Architecture

The project follows a structured data warehouse workflow:

**Source Systems → Data Ingestion → Data Transformation → Data Warehouse → SQL Analytics**

### Data Sources

- **ERP:** Provides business data such as product information, sales details, and related operational records.
- **CRM:** Provides customer information and customer-related records.
- **CSV Files:** Serve as the source files for importing data into SQL Server.

### Data Processing Workflow

1. **Data Extraction:** Load raw data from ERP and CRM CSV files.
2. **Data Quality:** Identify and resolve missing values, duplicates, inconsistent formats, and other data quality issues where applicable.
3. **Data Transformation:** Clean, standardize, and integrate data from both source systems.
4. **Data Modeling:** Organize the integrated data into a model suitable for analytical reporting.
5. **Data Analysis:** Use SQL queries to uncover business insights and calculate key metrics.

## 🧰 Technologies Used

- **Microsoft SQL Server** — Data storage and warehouse development
- **SQL** — Data extraction, transformation, validation, and analytical queries
- **CSV** — Source data format
- **SQL Server Management Studio (SSMS)** — Database development and query execution, if used

## 🗂️ Data Warehouse Design

The warehouse is designed to provide a consolidated view of sales and customer data.

The project focuses on the **latest available dataset**, rather than maintaining historical versions of records.

The data model aims to provide:

- Consistent customer and product information
- Integrated sales data across source systems
- Reliable relationships between business entities
- A simplified structure for analytical queries
- Clear documentation of tables, columns, and relationships

## 📊 Business Intelligence & Analytics

SQL-based analysis focuses on three key business areas.

### 1. Customer Behavior

- Analyze customer purchasing patterns.
- Identify high-value customers.
- Understand customer contributions to total sales.
- Compare sales performance across customer groups, where the data supports it.

### 2. Product Performance

- Identify top-selling products.
- Analyze product-level sales and revenue.
- Compare product performance across categories, where available.
- Identify products contributing most to overall sales.

### 3. Sales Trends

- Analyze sales performance over time.
- Calculate total sales and other relevant business metrics.
- Compare sales across available time periods.
- Identify patterns that can support business planning.

## 🧹 Data Quality & Transformation

Data quality is an essential part of the warehouse development process.

The project addresses relevant issues such as:

- Missing or invalid values
- Duplicate records
- Inconsistent naming conventions and formats
- Data type inconsistencies
- Incorrect or inconsistent relationships between source records
- Standardization of customer and product identifiers

The specific transformations depend on the issues identified in the source data.

## 📈 Expected Business Value

This project demonstrates how raw operational data can be transformed into a centralized analytical resource.

The resulting warehouse supports:

- More consistent sales reporting
- Improved data quality and reliability
- Easier access to integrated business information
- Better understanding of customer and product performance
- Data-driven business decisions

## 🚀 Skills Demonstrated

- SQL and relational database concepts
- Data ingestion from CSV files
- Data cleansing and transformation
- Data integration across multiple source systems
- Data warehouse design
- Dimensional data modeling
- Analytical SQL queries
- Data quality validation
- Technical documentation
- Translating business questions into analytical requirements

## 📚 Learning Outcomes

Through this project, I am developing practical experience with the fundamentals of data engineering, from ingesting and transforming raw data to designing a warehouse for analytics.

The project also strengthens my understanding of how data engineering and business intelligence work together to turn operational data into meaningful business insights.

## 👩‍💻 Author

**Maarij Shah**

GitHub: [MaarijShah](https://github.com/MaarijShah)

---

*This project is based on a guided data engineering tutorial and is being developed for hands-on learning and portfolio building.*
