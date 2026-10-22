/*
===============================================================================
DDL Script: Create Silver Layer Tables
===============================================================================

SCRIPT PURPOSE:
    This script creates the tables required for the Silver layer of a
    data warehouse.

    The Silver layer typically stores cleaned, standardized, and
    transformed data loaded from the Bronze layer.

WHAT THIS SCRIPT DOES:
    1. Checks whether each Silver table already exists.
    2. Drops the existing table if it is found.
    3. Creates the table again with the specified column definitions.
    4. Adds a data warehouse audit column (dwh_create_date) to record
       when a row is inserted, provided no value is explicitly supplied.

IMPORTANT NOTES:
    - This script is written for Microsoft SQL Server.
    - The 'silver' schema must already exist before running this script.
    - DROP TABLE permanently removes the table and its stored data.
    - Dropping and recreating tables can affect dependent objects,
      such as foreign keys, views, and other database objects.
    - GO is a batch separator recognized by SQL Server tools such as
      SQL Server Management Studio (SSMS).

===============================================================================
*/


/*
===============================================================================
1. CRM CUSTOMER INFORMATION TABLE
Table Name: silver.crm_cust_info
===============================================================================

PURPOSE:
    Stores customer information originating from the CRM source system.

    Typical data includes:
        - Customer ID
        - Customer business key
        - First and last names
        - Marital status
        - Gender
        - Customer creation date

TABLE MANAGEMENT:
    OBJECT_ID checks whether the specified database object exists.
    The second argument, 'U', identifies a user table.

    If the table exists, DROP TABLE removes it before it is recreated.

===============================================================================
*/

-- Check whether the CRM customer table already exists.
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL

    -- Remove the existing table and its data before rebuilding it.
    DROP TABLE silver.crm_cust_info;
GO

-- Create the CRM customer information table.
CREATE TABLE silver.crm_cust_info (

    -- Customer ID from the CRM system.
    -- INT stores whole-number values.
    cst_id INT,

    -- Customer business key used to identify the customer in the source.
    -- NVARCHAR(50) stores Unicode text with a maximum length of 50 characters.
    cst_key NVARCHAR(50),

    -- Customer's first name.
    cst_firstname NVARCHAR(50),

    -- Customer's last name.
    cst_lastname NVARCHAR(50),

    -- Customer's marital status, such as Married or Single.
    -- Actual values depend on the source data.
    cst_marital_status NVARCHAR(50),

    -- Customer's gender as provided by the source system.
    cst_gndr NVARCHAR(50),

    -- Date the customer record was created in the source system.
    -- DATE stores a calendar date without a time component.
    cst_create_date DATE,

    -- Data warehouse audit column.
    -- Records the current server date and time when an INSERT omits
    -- this column or uses the DEFAULT keyword.
    -- DATETIME2 supports fractional seconds and does not store a time zone.
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/*
===============================================================================
2. CRM PRODUCT INFORMATION TABLE
Table Name: silver.crm_prd_info
===============================================================================

PURPOSE:
    Stores product information obtained from the CRM source system.

    Typical data includes:
        - Product ID
        - Category ID
        - Product business key
        - Product name
        - Product cost
        - Product line
        - Product validity dates

DATE RANGE:
    prd_start_dt and prd_end_dt can represent the period during which
    a product record is valid.

    These dates may be used when implementing historical tracking
    or slowly changing dimension logic.

===============================================================================
*/

-- Check whether the CRM product table exists.
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL

    -- Drop the existing product table before recreating it.
    DROP TABLE silver.crm_prd_info;
GO

-- Create the CRM product information table.
CREATE TABLE silver.crm_prd_info (

    -- Unique product identifier from the source system.
    prd_id INT,

    -- Category identifier associated with the product.
    -- Stored as text because source category keys may contain characters.
    cat_id NVARCHAR(50),

    -- Product business key used to identify the product in the source.
    prd_key NVARCHAR(50),

    -- Name or description of the product.
    prd_nm NVARCHAR(50),

    -- Product cost.
    -- INT is suitable only when fractional monetary values are not required.
    prd_cost INT,

    -- Product line or classification, such as a source-defined product group.
    prd_line NVARCHAR(50),

    -- Start date indicating when the product record becomes valid.
    prd_start_dt DATE,

    -- End date indicating when the product record stops being valid.
    -- NULL may be used for products with no recorded end date.
    prd_end_dt DATE,

    -- Audit timestamp recording when the row is inserted using the default.
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/*
===============================================================================
3. CRM SALES DETAILS TABLE
Table Name: silver.crm_sales_details
===============================================================================

PURPOSE:
    Stores sales transaction details from the CRM source system.

    Typical data includes:
        - Sales order number
        - Product key
        - Customer ID
        - Order, shipping, and due dates
        - Sales amount
        - Quantity sold
        - Unit price

DATA RELATIONSHIPS:
    sls_prd_key may be used to match a product business key in the
    product table.

    sls_cust_id may be used to match a customer identifier in the
    customer table.

    These relationships are not enforced by this DDL because no
    PRIMARY KEY or FOREIGN KEY constraints are defined.

DATE COLUMNS:
    All transaction dates use DATE, so they contain no time component.

===============================================================================
*/

-- Check whether the CRM sales details table exists.
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL

    -- Drop the existing sales table before rebuilding it.
    DROP TABLE silver.crm_sales_details;
GO

-- Create the CRM sales details table.
CREATE TABLE silver.crm_sales_details (

    -- Sales order number identifying the transaction or order.
    -- Stored as text to preserve letters, leading zeros, or separators.
    sls_ord_num NVARCHAR(50),

    -- Product business key associated with the sales transaction.
    sls_prd_key NVARCHAR(50),

    -- Customer ID associated with the sales transaction.
    sls_cust_id INT,

    -- Date on which the sales order was placed.
    sls_order_dt DATE,

    -- Date on which the order was shipped.
    sls_ship_dt DATE,

    -- Date on which the order is due for delivery or fulfillment.
    sls_due_dt DATE,

    -- Total sales amount for the transaction or line.
    -- Confirm the source definition before assuming its calculation.
    sls_sales INT,

    -- Number of units sold.
    sls_quantity INT,

    -- Unit selling price.
    -- INT cannot store fractional values.
    sls_price INT,

    -- Audit timestamp populated by the default when applicable.
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/*
===============================================================================
4. ERP CUSTOMER LOCATION TABLE
Table Name: silver.erp_loc_a101
===============================================================================

PURPOSE:
    Stores customer location information from the ERP source system.

    Typical data includes:
        - Customer identifier
        - Country

CUSTOMER IDENTIFIER:
    cid is stored as NVARCHAR(50) because source identifiers may contain
    letters, prefixes, or leading zeros.

    If the source customer ID has a prefix that must be removed or
    standardized, that transformation should be performed during ETL
    processing rather than assumed by this table definition.

===============================================================================
*/

-- Check whether the ERP customer location table exists.
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL

    -- Drop the existing location table before recreating it.
    DROP TABLE silver.erp_loc_a101;
GO

-- Create the ERP customer location table.
CREATE TABLE silver.erp_loc_a101 (

    -- Customer identifier from the ERP source.
    cid NVARCHAR(50),

    -- Country associated with the customer.
    -- This may contain a country name, abbreviation, or source-specific value.
    cntry NVARCHAR(50),

    -- Audit timestamp recording the insertion time when the default applies.
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/*
===============================================================================
5. ERP CUSTOMER DEMOGRAPHICS TABLE
Table Name: silver.erp_cust_az12
===============================================================================

PURPOSE:
    Stores additional customer demographic information from the ERP system.

    Typical data includes:
        - Customer identifier
        - Birth date
        - Gender

DATA INTEGRATION:
    The cid column can be used to match customer records between ERP
    and CRM systems after the relevant identifiers have been standardized.

    bdate uses DATE because a birth date does not normally require a
    time-of-day component.

===============================================================================
*/

-- Check whether the ERP customer demographics table exists.
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL

    -- Drop the existing demographics table before recreating it.
    DROP TABLE silver.erp_cust_az12;
GO

-- Create the ERP customer demographics table.
CREATE TABLE silver.erp_cust_az12 (

    -- Customer identifier from the ERP source.
    cid NVARCHAR(50),

    -- Customer's birth date.
    -- DATE stores the year, month, and day without a time component.
    bdate DATE,

    -- Gender value supplied by the source system.
    -- NVARCHAR(50) allows different source labels to be stored.
    gen NVARCHAR(50),

    -- Audit timestamp populated by the default when applicable.
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/*
===============================================================================
6. ERP PRODUCT CATEGORY TABLE
Table Name: silver.erp_px_cat_g1v2
===============================================================================

PURPOSE:
    Stores product category and classification information from the ERP
    source system.

    Typical data includes:
        - Category identifier
        - Category name
        - Subcategory name
        - Maintenance indicator

DATA INTEGRATION:
    The id column can be used to connect product category information
    to product records after the source keys have been standardized.

    The maintenance column is stored as text because the source may
    provide values such as Yes/No, True/False, or other labels.

===============================================================================
*/

-- Check whether the ERP product category table exists.
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL

    -- Drop the existing product category table before recreating it.
    DROP TABLE silver.erp_px_cat_g1v2;
GO

-- Create the ERP product category table.
CREATE TABLE silver.erp_px_cat_g1v2 (

    -- Category identifier from the ERP source.
    -- Stored as text to preserve source key formatting.
    id NVARCHAR(50),

    -- Main product category name.
    cat NVARCHAR(50),

    -- Subcategory name within the main category.
    subcat NVARCHAR(50),

    -- Maintenance indicator or maintenance-related classification.
    -- Actual meaning and allowed values depend on the source system.
    maintenance NVARCHAR(50),

    -- Audit timestamp populated by the default when applicable.
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/*
===============================================================================
END OF SCRIPT
===============================================================================

RESULT:
    The script creates the following six tables in the Silver schema:

    1. silver.crm_cust_info
       CRM customer information.

    2. silver.crm_prd_info
       CRM product information.

    3. silver.crm_sales_details
       CRM sales transaction details.

    4. silver.erp_loc_a101
       ERP customer location information.

    5. silver.erp_cust_az12
       ERP customer demographic information.

    6. silver.erp_px_cat_g1v2
       ERP product category information.

IMPORTANT DESIGN CONSIDERATIONS:
    - No PRIMARY KEY constraints have been defined.
    - No FOREIGN KEY constraints have been defined.
    - All columns allow NULL values unless SQL Server applies another
      constraint or rule; no NOT NULL constraints are defined here.
    - The audit timestamp has a DEFAULT but is not automatically updated
      when an existing row is modified.
    - GETDATE() returns the current SQL Server system date and time.
    - DATETIME2 is the destination data type; SQL Server converts the
      GETDATE() result to DATETIME2 when assigning the default.
    - Re-running this script drops the existing tables and their data.
      Use caution in any environment containing data you need to preserve.

===============================================================================
*/
