
-- Quality Checks
-- This script checks the data in the Gold layer to make sure everything is correct.


-- =============================================
-- Check Customer Dimension
-- =============================================

-- Check if any customer keys are duplicated
-- Expected result: No rows should be returned
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- =============================================
-- Check Product Dimension
-- =============================================

-- Check if any product keys are duplicated
-- Expected result: No rows should be returned
SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- =============================================
-- Check Sales Fact
-- =============================================

-- Check if every sale is connected to an existing customer and product
-- Find sales records that have no matching customer or product
SELECT *
FROM gold.fact_sales f

-- Match sales with customer information
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key

-- Match sales with product information
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key

-- Show sales where the customer or product is missing
WHERE p.product_key IS NULL
   OR c.customer_key IS NULL;
