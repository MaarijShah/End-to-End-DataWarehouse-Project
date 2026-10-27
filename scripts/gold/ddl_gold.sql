Use dataWarehouse;

/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer of the data warehouse.

    The Gold layer contains business-ready dimension and fact views organized
    using a Star Schema design for analytics and reporting.

    - Dimension views provide descriptive information about customers
      and products.
    - The fact view contains sales transactions and links them to the
      corresponding customer and product dimensions.

    Data Source:
        Silver layer tables.

Usage:
    These views can be queried directly by reporting tools, dashboards,
    and analytical queries.
===============================================================================
*/


-- =============================================================================
-- Create Dimension: gold.dim_customers
-- Purpose:
--     Combines CRM and ERP customer data to create a unified customer dimension.
-- =============================================================================

-- Drop the existing view if it already exists.
-- The 'V' parameter specifies that the object must be a view.
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

-- Create the customer dimension view.
CREATE VIEW gold.dim_customers AS
SELECT
    -- Generate a surrogate key for each customer.
    -- ROW_NUMBER assigns sequential numbers based on customer ID.
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,

    -- Customer identification attributes from the CRM system.
    ci.cst_id              AS customer_id,
    ci.cst_key             AS customer_number,
    ci.cst_firstname       AS first_name,
    ci.cst_lastname        AS last_name,

    -- Country information obtained from the ERP location table.
    la.cntry               AS country,

    -- Customer marital status from the CRM system.
    ci.cst_marital_status  AS marital_status,

    -- Determine the customer's gender.
    -- CRM is the primary source.
    -- If CRM contains 'n/a', use the ERP gender instead.
    -- If both sources are unavailable, return 'n/a'.
    CASE
        WHEN ci.cst_gndr != 'n/a'
            THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END                    AS gender,

    -- Customer birthdate from the ERP customer table.
    ca.bdate               AS birthdate,

    -- Date the customer record was created in the CRM system.
    ci.cst_create_date     AS create_date

-- CRM customer information is the primary source for this dimension.
FROM silver.crm_cust_info ci

-- Retrieve additional customer information from the ERP system.
-- LEFT JOIN preserves CRM customers even when ERP data is missing.
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid

-- Retrieve the customer's country from the ERP location table.
-- LEFT JOIN preserves customers without matching location records.
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;
GO


-- =============================================================================
-- Create Dimension: gold.dim_products
-- Purpose:
--     Combines CRM product information with ERP product category details.
--     Includes only current products and excludes historical product records.
-- =============================================================================

-- Drop the existing view if it already exists.
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

-- Create the product dimension view.
CREATE VIEW gold.dim_products AS
SELECT
    -- Generate a surrogate key for each product.
    -- Products are ordered by start date and product key.
    ROW_NUMBER() OVER (
        ORDER BY pn.prd_start_dt, pn.prd_key
    ) AS product_key,

    -- Product identification and descriptive information.
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,

    -- Product category information from the ERP system.
    pn.cat_id       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance,

    -- Product cost and classification attributes.
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,

    -- Date the current product record became effective.
    pn.prd_start_dt AS start_date

-- Retrieve product information from the CRM system.
FROM silver.crm_prd_info pn

-- Enrich products with category, subcategory, and maintenance details.
-- LEFT JOIN preserves products even if category information is missing.
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id

-- Include only current product records.
-- Products with an end date are considered historical records.
WHERE pn.prd_end_dt IS NULL;
GO


-- =============================================================================
-- Create Fact View: gold.fact_sales
-- Purpose:
--     Combines sales transactions with customer and product surrogate keys.
--     Establishes relationships between the fact view and both dimensions.
-- =============================================================================

-- Drop the existing view if it already exists.
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

-- Create the sales fact view.
CREATE VIEW gold.fact_sales AS
SELECT
    -- Sales order identifier.
    sd.sls_ord_num  AS order_number,

    -- Product surrogate key from the product dimension.
    -- Used to link each sales transaction to a product.
    pr.product_key  AS product_key,

    -- Customer surrogate key from the customer dimension.
    -- Used to link each sales transaction to a customer.
    cu.customer_key AS customer_key,

    -- Sales order lifecycle dates.
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,

    -- Numeric measures used for sales analysis.
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price

-- Retrieve transactional sales data from the CRM system.
FROM silver.crm_sales_details sd

-- Match each transaction to its product dimension record.
-- The product number is used to look up the surrogate key.
-- LEFT JOIN preserves sales records even when no product matches.
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number

-- Match each transaction to its customer dimension record.
-- The CRM customer ID is used to look up the surrogate key.
-- LEFT JOIN preserves sales records even when no customer matches.
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;
GO
