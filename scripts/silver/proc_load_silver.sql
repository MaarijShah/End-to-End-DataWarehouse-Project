
/*
===============================================================================
Stored Procedure: silver.load_silver
Purpose: Load cleaned data from Bronze tables into Silver tables
Database: DataWarehouse
===============================================================================

What this procedure does:
    1. Reads raw data from the Bronze layer.
    2. Cleans and standardizes the data.
    3. Removes duplicate customer records.
    4. Validates and converts dates.
    5. Truncates and reloads the Silver tables.
    6. Prints progress messages and execution duration.
    7. Handles errors using TRY...CATCH.

IMPORTANT:
    Run the Silver DDL script first.
    This procedure replaces the existing contents of Silver tables
    each time it is executed.
===============================================================================
*/

USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    SET NOCOUNT ON;

    -- Variables for tracking execution time.
    DECLARE
        @start_time       DATETIME2,
        @end_time         DATETIME2,
        @batch_start_time DATETIME2,
        @batch_end_time   DATETIME2;

    BEGIN TRY

        -- Start a transaction so the Silver reload can be rolled back
        -- if an error occurs during processing.
        BEGIN TRANSACTION;

        SET @batch_start_time = GETDATE();

        PRINT '============================================';
        PRINT 'Loading Silver Layer';
        PRINT '============================================';

        /*==============================================================
          1. LOAD CRM CUSTOMER INFORMATION
        ==============================================================*/

        SET @start_time = GETDATE();

        PRINT 'Loading silver.crm_cust_info';

        -- Remove existing Silver customer records.
        TRUNCATE TABLE silver.crm_cust_info;

        -- Insert cleaned customer data.
        INSERT INTO silver.crm_cust_info
        (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,

            -- Remove leading and trailing spaces from names.
            TRIM(cst_firstname),
            TRIM(cst_lastname),

            -- Convert source marital status codes into readable values.
            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'S'
                    THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M'
                    THEN 'Married'
                ELSE 'n/a'
            END,

            -- Standardize gender values.
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'F'
                    THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M'
                    THEN 'Male'
                ELSE 'n/a'
            END,

            cst_create_date

        FROM
        (
            -- Rank records for each customer.
            SELECT *,
                ROW_NUMBER() OVER
                (
                    PARTITION BY cst_id
                    ORDER BY cst_create_date DESC
                ) AS row_num
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) AS customer_data

        -- Keep only the latest record for each customer ID.
        WHERE row_num = 1;

        SET @end_time = GETDATE();

        PRINT 'Customer load completed in '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds.';


        /*==============================================================
          2. LOAD CRM PRODUCT INFORMATION
        ==============================================================*/

        SET @start_time = GETDATE();

        PRINT 'Loading silver.crm_prd_info';

        TRUNCATE TABLE silver.crm_prd_info;

        INSERT INTO silver.crm_prd_info
        (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,

            -- Extract category ID from the product key.
            -- Example: AC-HE-1001 becomes AC_HE.
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),

            -- Extract the product-specific portion of the key.
            SUBSTRING(prd_key, 7, LEN(prd_key)),

            -- Trim product names.
            TRIM(prd_nm),

            -- Replace missing product costs with zero.
            ISNULL(prd_cost, 0),

            -- Standardize product line codes.
            CASE
                WHEN UPPER(TRIM(prd_line)) = 'M'
                    THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'R'
                    THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'S'
                    THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'T'
                    THEN 'Touring'
                ELSE 'n/a'
            END,

            -- Keep product start dates as DATE values.
            TRY_CONVERT(DATE, prd_start_dt),

            -- Calculate the end date as one day before the next
            -- start date for the same original product key.
            DATEADD
            (
                DAY,
                -1,
                LEAD(TRY_CONVERT(DATE, prd_start_dt)) OVER
                (
                    PARTITION BY prd_key
                    ORDER BY TRY_CONVERT(DATE, prd_start_dt)
                )
            )

        FROM bronze.crm_prd_info;

        SET @end_time = GETDATE();

        PRINT 'Product load completed in '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds.';


        /*==============================================================
          3. LOAD CRM SALES DETAILS
        ==============================================================*/

        SET @start_time = GETDATE();

        PRINT 'Loading silver.crm_sales_details';

        TRUNCATE TABLE silver.crm_sales_details;

        INSERT INTO silver.crm_sales_details
        (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            -- Convert YYYYMMDD source values into DATE.
            -- Invalid dates and zero values become NULL.
            CASE
                WHEN LEN(TRIM(CONVERT(VARCHAR(30), sls_order_dt))) = 8
                    THEN TRY_CONVERT
                    (
                        DATE,
                        CONVERT(VARCHAR(8), sls_order_dt),
                        112
                    )
                ELSE NULL
            END,

            CASE
                WHEN LEN(TRIM(CONVERT(VARCHAR(30), sls_ship_dt))) = 8
                    THEN TRY_CONVERT
                    (
                        DATE,
                        CONVERT(VARCHAR(8), sls_ship_dt),
                        112
                    )
                ELSE NULL
            END,

            CASE
                WHEN LEN(TRIM(CONVERT(VARCHAR(30), sls_due_dt))) = 8
                    THEN TRY_CONVERT
                    (
                        DATE,
                        CONVERT(VARCHAR(8), sls_due_dt),
                        112
                    )
                ELSE NULL
            END,

            -- Recalculate sales if the original value is missing,
            -- nonpositive, or inconsistent with quantity and price.
            CASE
                WHEN sls_sales IS NULL OR sls_sales <= 0
                  OR sls_sales <> sls_quantity * ABS(sls_price)
                    THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END,

            sls_quantity,

            -- Use the original price when valid.
            -- Otherwise derive it from sales and quantity when possible.
            CASE
                WHEN sls_price IS NULL OR sls_price <= 0
                    THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END

        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();

        PRINT 'Sales load completed in '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds.';


        /*==============================================================
          4. LOAD ERP CUSTOMER DEMOGRAPHICS
        ==============================================================*/

        SET @start_time = GETDATE();

        PRINT 'Loading silver.erp_cust_az12';

        TRUNCATE TABLE silver.erp_cust_az12;

        INSERT INTO silver.erp_cust_az12
        (
            cid,
            bdate,
            gen
        )
        SELECT
            -- Remove the NAS prefix when it appears at the beginning.
            CASE
                WHEN UPPER(TRIM(cid)) LIKE 'NAS%'
                    THEN SUBSTRING(TRIM(cid), 4, LEN(TRIM(cid)))
                ELSE TRIM(cid)
            END,

            -- Convert future birth dates to NULL.
            CASE
                WHEN TRY_CONVERT(DATE, bdate) > CAST(GETDATE() AS DATE)
                    THEN NULL
                ELSE TRY_CONVERT(DATE, bdate)
            END,

            -- Standardize gender values.
            CASE
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE')
                    THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')
                    THEN 'Male'
                ELSE 'n/a'
            END

        FROM bronze.erp_cust_az12;

        SET @end_time = GETDATE();

        PRINT 'ERP customer load completed in '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds.';


        /*==============================================================
          5. LOAD ERP CUSTOMER LOCATIONS
        ==============================================================*/

        SET @start_time = GETDATE();

        PRINT 'Loading silver.erp_loc_a101';

        TRUNCATE TABLE silver.erp_loc_a101;

        INSERT INTO silver.erp_loc_a101
        (
            cid,
            cntry
        )
        SELECT
            -- Remove hyphens and surrounding spaces from customer IDs.
            REPLACE(TRIM(cid), '-', ''),

            -- Standardize common country codes.
            CASE
                WHEN TRIM(cntry) = 'DE'
                    THEN 'Germany'
                WHEN UPPER(TRIM(cntry)) IN ('US', 'USA')
                    THEN 'United States'
                WHEN TRIM(cntry) = ''
                  OR cntry IS NULL
                    THEN 'n/a'
                ELSE TRIM(cntry)
            END

        FROM bronze.erp_loc_a101;

        SET @end_time = GETDATE();

        PRINT 'ERP location load completed in '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds.';


        /*==============================================================
          6. LOAD ERP PRODUCT CATEGORIES
        ==============================================================*/

        SET @start_time = GETDATE();

        PRINT 'Loading silver.erp_px_cat_g1v2';

        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        INSERT INTO silver.erp_px_cat_g1v2
        (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            TRIM(id),
            TRIM(cat),
            TRIM(subcat),

            -- Standardize the maintenance indicator.
            CASE
                WHEN UPPER(TRIM(maintenance)) IN ('YES', 'Y', 'TRUE')
                    THEN 'Yes'
                WHEN UPPER(TRIM(maintenance)) IN ('NO', 'N', 'FALSE')
                    THEN 'No'
                WHEN maintenance IS NULL
                  OR TRIM(maintenance) = ''
                    THEN 'n/a'
                ELSE TRIM(maintenance)
            END

        FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();

        PRINT 'ERP product category load completed in '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds.';


        /*==============================================================
          FINISH THE SILVER LOAD
        ==============================================================*/

        -- Commit all six table loads together.
        COMMIT TRANSACTION;

        SET @batch_end_time = GETDATE();

        PRINT '============================================';
        PRINT 'Silver Layer Loading Completed Successfully';
        PRINT 'Total duration: '
            + CAST
              (
                  DATEDIFF(SECOND, @batch_start_time, @batch_end_time)
                  AS NVARCHAR(20)
              )
            + ' seconds.';
        PRINT '============================================';

    END TRY
    BEGIN CATCH

        -- Undo all changes made by this procedure if an error occurs.
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        PRINT '============================================';
        PRINT 'ERROR WHILE LOADING SILVER LAYER';
        PRINT 'Error number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'Error message: ' + ERROR_MESSAGE();
        PRINT 'Error line: ' + CAST(ERROR_LINE() AS NVARCHAR(20));
        PRINT '============================================';

        -- Return the original SQL Server error to the caller.
        THROW;

    END CATCH;
END;
GO
