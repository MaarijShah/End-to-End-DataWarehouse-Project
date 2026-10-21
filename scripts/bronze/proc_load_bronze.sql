-- ============================================================
-- Stored Procedure: bronze.load_bronze
-- Description:
--     Loads raw CRM and ERP data from CSV files into the
--     Bronze layer of the Data Warehouse.
--
-- Process:
--     1. Truncates existing data from each Bronze table.
--     2. Loads fresh data using BULK INSERT.
--     3. Tracks loading duration for each table.
--     4. Logs batch completion and handles loading errors.
--
-- Note:
--     Update the source file paths according to your environment.
-- ============================================================

USE DataWarehouse;
GO

-- Create or modify the stored procedure for loading the Bronze layer.
CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    -- Prevent SQL Server from returning row-count messages
    -- after each statement.
    SET NOCOUNT ON;

    -- Variables for tracking individual table load times
    -- and the overall batch execution time.
    DECLARE
        @start_time DATETIME,
        @end_time DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time DATETIME;

    BEGIN TRY

        -- Record the start time of the entire Bronze layer load.
        SET @batch_start_time = GETDATE();

        PRINT '================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '================================================';

        -- ====================================================
        -- 1. LOAD CRM SOURCE TABLES
        -- ====================================================

        PRINT '------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------------';

        -- ----------------------------------------------------
        -- CRM Customer Information
        -- Source: cust_info.csv
        -- Target: bronze.crm_cust_info
        -- ----------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_cust_info';

        -- Remove existing records before loading fresh source data.
        TRUNCATE TABLE bronze.crm_cust_info;

        -- Import customer information from the source CSV file.
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\maari\Downloads\dwh_project\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,           -- Skip the CSV header row.
            FIELDTERMINATOR = ',',  -- Separate fields using commas.
            TABLOCK                 -- Use a table-level bulk load lock.
        );

        -- Calculate and display the duration of this table load.
        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';
        PRINT '>> -------------';

        -- ----------------------------------------------------
        -- CRM Product Information
        -- Source: prd_info.csv
        -- Target: bronze.crm_prd_info
        -- ----------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_prd_info';

        -- Clear existing product records.
        TRUNCATE TABLE bronze.crm_prd_info;

        -- Load product information from the source CSV file.
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\maari\Downloads\dwh_project\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        -- Log the product table loading duration.
        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';
        PRINT '>> -------------';

        -- ----------------------------------------------------
        -- CRM Sales Details
        -- Source: sales_details.csv
        -- Target: bronze.crm_sales_details
        -- ----------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_sales_details';

        -- Clear existing sales transaction records.
        TRUNCATE TABLE bronze.crm_sales_details;

        -- Load sales transaction data from the source CSV file.
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\maari\Downloads\dwh_project\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        -- Log the sales table loading duration.
        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';
        PRINT '>> -------------';

        -- ====================================================
        -- 2. LOAD ERP SOURCE TABLES
        -- ====================================================

        PRINT '------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '------------------------------------------------';

        -- ----------------------------------------------------
        -- ERP Location Information
        -- Source: LOC_A101.csv
        -- Target: bronze.erp_loc_a101
        -- ----------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_loc_a101';

        -- Clear existing location records.
        TRUNCATE TABLE bronze.erp_loc_a101;

        -- Load location data from the ERP source file.
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\maari\Downloads\dwh_project\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        -- Log the location table loading duration.
        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';
        PRINT '>> -------------';

        -- ----------------------------------------------------
        -- ERP Customer Information
        -- Source: CUST_AZ12.csv
        -- Target: bronze.erp_cust_az12
        -- ----------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_cust_az12';

        -- Clear existing ERP customer records.
        TRUNCATE TABLE bronze.erp_cust_az12;

        -- Load customer data from the ERP source file.
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\maari\Downloads\dwh_project\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        -- Log the ERP customer table loading duration.
        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';
        PRINT '>> -------------';

        -- ----------------------------------------------------
        -- ERP Product Category Information
        -- Source: PX_CAT_G1V2.csv
        -- Target: bronze.erp_px_cat_g1v2
        -- ----------------------------------------------------

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';

        -- Clear existing product category records.
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        -- Load product category and related reference data.
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\maari\Downloads\dwh_project\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        -- Log the product category table loading duration.
        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';
        PRINT '>> -------------';

        -- ====================================================
        -- 3. BATCH COMPLETION SUMMARY
        -- ====================================================

        -- Record the end time and calculate the total execution time.
        SET @batch_end_time = GETDATE();

        PRINT '==========================================';
        PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: '
            + CAST(
                DATEDIFF(SECOND, @batch_start_time, @batch_end_time)
                AS NVARCHAR
            )
            + ' seconds';
        PRINT '==========================================';

    END TRY

    BEGIN CATCH

        -- ====================================================
        -- 4. ERROR HANDLING
        -- ====================================================

        -- Display SQL Server error details if any loading step fails.
        PRINT '===================================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '===================================================';

        -- Note: This handler logs the error but does not rethrow it.
        -- Use THROW if the calling process must detect the failure.

    END CATCH;

END;
GO

-- ============================================================
-- EXECUTION
-- Run the stored procedure to load all Bronze layer tables.
-- ============================================================

EXEC bronze.load_bronze;
GO
