CREATE OR ALTER PROCEDURE bronze.load_bronze
    @data_directory NVARCHAR(4000)
AS
BEGIN
    -- BULK INSERT reads server-side files; the runner resolves the project-relative directory.
    IF NULLIF(TRIM(@data_directory), '') IS NULL
        THROW 50001, 'A data directory is required.', 1;

    IF RIGHT(@data_directory, 1) NOT IN ('\', '/')
        SET @data_directory = @data_directory + N'\';

    DECLARE
        @bulk_sql NVARCHAR(MAX),
        @start_time DATETIME,
        @end_time DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT 'Loading Bronze Layer';

        PRINT 'Loading BSS Tables';

        SET @start_time = GETDATE();
        PRINT('>> Truncating Table: bronze.bss_customer_accounts')
        TRUNCATE TABLE bronze.bss_customer_accounts;
        PRINT('>> Inserting Data Into: bronze.bss_customer_accounts')
        SET @bulk_sql = N'BULK INSERT bronze.bss_customer_accounts FROM '''
            + REPLACE(@data_directory + N'source_bss\customer_accounts.csv', N'''', N'''''')
            + N''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);';
        EXEC sys.sp_executesql @bulk_sql;
        SET @end_time = GETDATE();
        PRINT('>> Load duration: ') + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' ms';

        SET @start_time = GETDATE();
        PRINT('>> Truncating Table: bronze.bss_monthly_usage')
        TRUNCATE TABLE bronze.bss_monthly_usage;
        PRINT('>> Inserting Data Into: bronze.bss_monthly_usage')
        SET @bulk_sql = N'BULK INSERT bronze.bss_monthly_usage FROM '''
            + REPLACE(@data_directory + N'source_bss\monthly_usage.csv', N'''', N'''''')
            + N''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);';
        EXEC sys.sp_executesql @bulk_sql;
        SET @end_time = GETDATE();
        PRINT('>> Load duration: ') + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' ms';

        SET @start_time = GETDATE();
        PRINT('>> Truncating Table: bronze.bss_service_plans')
        TRUNCATE TABLE bronze.bss_service_plans;
        PRINT('>> Inserting Data Into: bronze.bss_service_plans')
        SET @bulk_sql = N'BULK INSERT bronze.bss_service_plans FROM '''
            + REPLACE(@data_directory + N'source_bss\service_plans.csv', N'''', N'''''')
            + N''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);';
        EXEC sys.sp_executesql @bulk_sql;
        SET @end_time = GETDATE();
        PRINT('>> Load duration: ') + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' ms';

        PRINT 'Loading OSS Tables';

        SET @start_time = GETDATE();
        PRINT('>> Truncating Table: bronze.oss_customer_addresses')
        TRUNCATE TABLE bronze.oss_customer_addresses;
        PRINT('>> Inserting Data Into: bronze.oss_customer_addresses')
        SET @bulk_sql = N'BULK INSERT bronze.oss_customer_addresses FROM '''
            + REPLACE(@data_directory + N'source_oss\customer_addresses.csv', N'''', N'''''')
            + N''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);';
        EXEC sys.sp_executesql @bulk_sql;
        SET @end_time = GETDATE();
        PRINT('>> Load duration: ') + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' ms';

        SET @start_time = GETDATE();
        PRINT('>> Truncating Table: bronze.oss_customer_demographics')
        TRUNCATE TABLE bronze.oss_customer_demographics;
        PRINT('>> Inserting Data Into: bronze.oss_customer_demographics')
        SET @bulk_sql = N'BULK INSERT bronze.oss_customer_demographics FROM '''
            + REPLACE(@data_directory + N'source_oss\customer_demographics.csv', N'''', N'''''')
            + N''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);';
        EXEC sys.sp_executesql @bulk_sql;
        SET @end_time = GETDATE();
        PRINT('>> Load duration: ') + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' ms';

        SET @start_time = GETDATE();
        PRINT('>> Truncating Table: bronze.oss_plan_categories')
        TRUNCATE TABLE bronze.oss_plan_categories;
        PRINT('>> Inserting Data Into: bronze.oss_plan_categories')
        SET @bulk_sql = N'BULK INSERT bronze.oss_plan_categories FROM '''
            + REPLACE(@data_directory + N'source_oss\plan_categories.csv', N'''', N'''''')
            + N''' WITH (FIRSTROW = 2, FIELDTERMINATOR = '','', TABLOCK);';
        EXEC sys.sp_executesql @bulk_sql;
        SET @end_time = GETDATE();
        PRINT('>> Load duration: ') + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' ms';

        SET @batch_end_time = GETDATE();
        PRINT 'Loading Bronze Layer is Completed';
        PRINT '>> Total Load Duration: '
            + CAST(DATEDIFF(MILLISECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(20)) + ' ms';
    END TRY
    BEGIN CATCH
        PRINT 'ERROR OCCURRED DURING BRONZE LAYER LOADING';
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Procedure: ' + COALESCE(ERROR_PROCEDURE(), 'Unknown');
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR(20));
        THROW;
    END CATCH
END



