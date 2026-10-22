/*
===============================================================================
Data Quality Checks - Silver Layer
===============================================================================
Script Purpose:
    This script performs data quality checks on tables in the Silver Layer
    to ensure that the data is accurate, consistent, complete, and properly
    standardized before it is used for reporting and analytics.

Quality Checks Include:
    1. Primary Key Validation:
       Identify NULL or duplicate primary key values.

    2. Data Cleansing Validation:
       Detect unwanted leading or trailing spaces in string columns.

    3. Data Standardization:
       Review distinct values to identify inconsistent labels or formats.

    4. Data Integrity Validation:
       Identify invalid dates, incorrect date sequences, and inconsistent
       relationships between related columns.

    5. Business Rule Validation:
       Ensure values such as cost, sales, quantity, price, and birthdates
       satisfy the expected business rules.

Usage Notes:
    - Execute these checks after loading and transforming data into the
      Silver Layer.
    - Investigate unexpected results to identify data quality issues.
    - Queries marked "Expectation: No Results" should return zero rows
      when the corresponding quality rules are satisfied.
    - Queries using DISTINCT are intended for manual review of the values
      and may return results even when the data is valid.

===============================================================================
*/


-- ====================================================================
-- 1. Quality Checks: silver.crm_cust_info
-- ====================================================================

-- Check for NULL or Duplicate Customer IDs
-- Purpose:
--   Verify that cst_id uniquely identifies each customer and is not NULL.
-- Expectation:
--   No results. Each customer must have a unique, non-NULL identifier.

SELECT
    cst_id,
    COUNT(*) AS record_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


-- Check for Unwanted Spaces in Customer Keys
-- Purpose:
--   Identify customer keys containing leading or trailing spaces.
--   Such spaces can cause incorrect joins and matching issues.
-- Expectation:
--   No results. All customer keys should be properly trimmed.

SELECT
    cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);


-- Review Customer Marital Status Values
-- Purpose:
--   Display all distinct marital status values to identify inconsistent
--   labels, unexpected categories, or differences in standardization.
-- Expectation:
--   All values should follow the agreed business terminology.
-- Note:
--   Review the results manually; this query may return valid values.

SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info;



-- ====================================================================
-- 2. Quality Checks: silver.crm_prd_info
-- ====================================================================

-- Check for NULL or Duplicate Product IDs
-- Purpose:
--   Ensure that prd_id uniquely identifies each product and contains
--   no NULL values.
-- Expectation:
--   No results. Product IDs must be unique and non-NULL.

SELECT
    prd_id,
    COUNT(*) AS record_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;


-- Check for Unwanted Spaces in Product Names
-- Purpose:
--   Identify product names with leading or trailing spaces that may
--   affect searching, grouping, or reporting.
-- Expectation:
--   No results. Product names should be properly trimmed.

SELECT
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- Check for NULL or Negative Product Costs
-- Purpose:
--   Verify that product costs are populated and non-negative.
--   Negative costs may indicate incorrect source data or transformation
--   errors.
-- Expectation:
--   No results, assuming all products must have a valid, non-negative cost.
-- Note:
--   Zero-cost products are allowed by this check.

SELECT
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0
    OR prd_cost IS NULL;


-- Review Product Line Values
-- Purpose:
--   Identify all distinct product line categories and check for
--   inconsistent labels, unexpected values, or missing standardization.
-- Expectation:
--   Values should match the approved product line categories.

SELECT DISTINCT
    prd_line
FROM silver.crm_prd_info;


-- Check for Invalid Product Date Ranges
-- Purpose:
--   Identify records where the product end date occurs before the
--   product start date.
--   Such records represent an invalid chronological sequence.
-- Expectation:
--   No results. The end date must not precede the start date.
-- Note:
--   NULL date handling and open-ended product periods should be
--   evaluated according to the business rules.

SELECT
    *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;



-- ====================================================================
-- 3. Quality Checks: silver.crm_sales_details
-- ====================================================================

-- Check for Invalid Sales Dates in the Bronze Layer
-- Purpose:
--   Validate the original date values before conversion into proper
--   date data types in the Silver Layer.
--
--   The checks identify:
--     - Zero or non-positive date values.
--     - Values that do not contain exactly eight characters.
--     - Dates outside the permitted range of 1900-01-01 to 2050-01-01.
--
-- Expectation:
--   No invalid dates should be returned.
-- Note:
--   This check uses the Bronze Layer because the original date values
--   are needed to identify invalid source representations.
--   The query assumes dates are stored in YYYYMMDD format.

SELECT
    NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
    OR LEN(sls_due_dt) != 8
    OR sls_due_dt > 20500101
    OR sls_due_dt < 19000101;


-- Check for Invalid Sales Date Sequences
-- Purpose:
--   Verify that the order date does not occur after the shipping date
--   or the due date.
--   An order placed after its shipping or due date may indicate
--   incorrect dates or a data transformation issue.
-- Expectation:
--   No results. Order dates should not exceed the related dates.
-- Note:
--   NULL date values are not detected by these comparisons and may
--   require separate validation.

SELECT
    *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
    OR sls_order_dt > sls_due_dt;


-- Check Sales Amount Consistency
-- Purpose:
--   Verify that the recorded sales amount equals quantity multiplied
--   by unit price.
--
--   This check also identifies:
--     - NULL sales amounts, quantities, or prices.
--     - Zero or negative sales amounts.
--     - Zero or negative quantities.
--     - Zero or negative unit prices.
--
-- Expectation:
--   No results, assuming all sales records must contain positive,
--   non-NULL values and satisfy the sales calculation rule.
-- Note:
--   If rounding or discounts are permitted by the business rules,
--   the calculation may need to account for them.

SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
    OR sls_sales IS NULL
    OR sls_quantity IS NULL
    OR sls_price IS NULL
    OR sls_sales <= 0
    OR sls_quantity <= 0
    OR sls_price <= 0
ORDER BY
    sls_sales,
    sls_quantity,
    sls_price;



-- ====================================================================
-- 4. Quality Checks: silver.erp_cust_az12
-- ====================================================================

-- Check for Out-of-Range Customer Birthdates
-- Purpose:
--   Identify birthdates that fall before the defined minimum date
--   or after the current date.
--   Future birthdates and unusually old birthdates may indicate
--   invalid or incorrectly transformed source data.
-- Expectation:
--   No results. Birthdates should fall between 1924-01-01 and today.
-- Note:
--   The minimum birthdate is a business-defined validation rule and
--   should be adjusted if the requirements change.

SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
    OR bdate > GETDATE();


-- Review Customer Gender Values
-- Purpose:
--   Display all distinct gender values to identify inconsistent
--   labels, unexpected categories, or differences in standardization.
-- Expectation:
--   Values should follow the agreed terminology and coding standards.
-- Note:
--   Review the results manually; NULL or other values may require
--   separate business-rule validation.

SELECT DISTINCT
    gen
FROM silver.erp_cust_az12;



-- ====================================================================
-- 5. Quality Checks: silver.erp_loc_a101
-- ====================================================================

-- Review Country Values
-- Purpose:
--   List all distinct country values in alphabetical order to identify
--   inconsistent country names, abbreviations, spelling variations,
--   or unexpected values.
-- Expectation:
--   Country values should follow a consistent naming convention.
-- Note:
--   Manual review is required to determine which values need correction.

SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101
ORDER BY cntry;



-- ====================================================================
-- 6. Quality Checks: silver.erp_px_cat_g1v2
-- ====================================================================

-- Check for Unwanted Spaces in Category Attributes
-- Purpose:
--   Identify leading or trailing spaces in category, subcategory,
--   and maintenance fields.
--   Unwanted spaces can cause inconsistent grouping, filtering,
--   joins, and reporting results.
-- Expectation:
--   No results. All checked string fields should be properly trimmed.

SELECT
    *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
    OR subcat != TRIM(subcat)
    OR maintenance != TRIM(maintenance);


-- Review Maintenance Values
-- Purpose:
--   Display all distinct maintenance values to identify inconsistent
--   labels, unexpected categories, or non-standard terminology.
-- Expectation:
--   Values should match the approved maintenance classifications.
-- Note:
--   Review the results manually; distinct values are not necessarily
--   invalid.

SELECT DISTINCT
    maintenance
FROM silver.erp_px_cat_g1v2;


/*
===============================================================================
End of Silver Layer Data Quality Checks
===============================================================================
Summary:
    These checks help validate primary key integrity, string cleanliness,
    value standardization, date validity, and consistency between related
    business fields.

    Any unexpected results should be investigated and resolved according
    to the source data and the project's business rules before the data
    is used for downstream reporting and analytics.
===============================================================================
*/
