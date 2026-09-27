USE telco_dwh;
GO

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    SET NOCOUNT ON;

    IF @@TRANCOUNT > 0
    BEGIN
        SET XACT_ABORT OFF;
        RAISERROR('Run silver.load_silver outside an existing transaction.', 16, 1);
        RETURN;
    END;

    SET XACT_ABORT ON;
    SET LANGUAGE us_english;
    DECLARE
        @start_time DATETIME,
        @end_time DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time DATETIME;
    BEGIN TRY
        BEGIN TRANSACTION;
        SET @batch_start_time = GETDATE();
        PRINT 'Loading Silver Layer';

        PRINT 'Loading BSS Tables';

        SET @start_time = GETDATE();
        PRINT('>> Truncating Table: silver.bss_customer_accounts')
        TRUNCATE TABLE silver.bss_customer_accounts;
        PRINT('>> Inserting Data Into: silver.bss_customer_accounts')
        INSERT INTO silver.bss_customer_accounts(
            account_id,
            customer_key,
            first_name,
            last_name,
            email,
            join_date,
            contract_end_date,
            churn_status
        )
        SELECT
            TRY_CONVERT(INT, NULLIF(TRIM(account_id), '')) AS account_id,
            CASE
                WHEN LEFT(UPPER(TRIM(customer_key)), 4) = 'CUS-' AND LEN(TRIM(customer_key)) > 4 THEN UPPER(SUBSTRING(TRIM(customer_key), 5, LEN(TRIM(customer_key))))
                ELSE NULL
            END AS customer_key,
            NULLIF(TRIM(first_name), '') AS first_name,
            CASE
                WHEN UPPER(TRIM(last_name)) = 'N/A' THEN NULL
                ELSE NULLIF(TRIM(last_name), '')
            END AS last_name,
            CASE
                WHEN TRIM(email) LIKE '%.@%' OR LOWER(TRIM(email)) LIKE '%n/a@%' THEN NULL
                ELSE NULLIF(TRIM(email), '')
            END AS email,
            TRY_CONVERT(DATE, NULLIF(TRIM(join_date), ''), CASE WHEN join_date LIKE '%/%' THEN 101 ELSE 23 END) AS join_date,
            CASE
                WHEN UPPER(TRIM(contract_end_date)) = '(BLANK)' THEN NULL
                WHEN TRY_CONVERT(DATE, NULLIF(TRIM(contract_end_date), ''), 23)
                     < TRY_CONVERT(DATE, NULLIF(TRIM(join_date), ''), CASE WHEN join_date LIKE '%/%' THEN 101 ELSE 23 END) THEN NULL
                ELSE TRY_CONVERT(DATE, NULLIF(TRIM(contract_end_date), ''), 23)
            END AS contract_end_date,
            CAST(CASE
                WHEN UPPER(TRIM(churn_status)) IN ('T', 'TRUE') THEN 1
                WHEN UPPER(TRIM(churn_status)) IN ('F', 'FALSE') THEN 0
                ELSE NULL
            END AS BIT) AS churn_status
        FROM bronze.bss_customer_accounts;

        SET @end_time = GETDATE();
        PRINT('>> Load duration: ') + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' ms';

        SET @start_time = GETDATE();
        PRINT('>> Truncating Table: silver.bss_monthly_usage')
        TRUNCATE TABLE silver.bss_monthly_usage;
        PRINT('>> Inserting Data Into: silver.bss_monthly_usage')
        INSERT INTO silver.bss_monthly_usage(
            invoice_number,
            account_id,
            plan_sku,
            billing_period_start,
            billing_period_end,
            data_usage_gb,
            voice_minutes,
            sms_count,
            total_charge
        )
        SELECT
            NULLIF(TRIM(UPPER(invoice_number)), '') AS invoice_number,
            TRY_CONVERT(INT, NULLIF(TRIM(account_id), '')) AS account_id,
            NULLIF(TRIM(UPPER(plan_sku)), '') AS plan_sku,
            TRY_CONVERT(DATE, NULLIF(TRIM(billing_period_start), ''), 23) AS billing_period_start,
            TRY_CONVERT(DATE, NULLIF(TRIM(billing_period_end), ''), 23) AS billing_period_end,
            TRY_CONVERT(DECIMAL(10,2), NULLIF(TRIM(data_usage_gb), '')) AS data_usage_gb,
            TRY_CONVERT(INT, NULLIF(TRIM(voice_minutes), '')) AS voice_minutes,
            TRY_CONVERT(INT, NULLIF(TRIM(sms_count), '')) AS sms_count,
            TRY_CONVERT(DECIMAL(10,2), NULLIF(TRIM(REPLACE(total_charge, '$', '')), '')) AS total_charge
        FROM bronze.bss_monthly_usage;

        SET @end_time = GETDATE();
        PRINT('>> Load duration: ') + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' ms';

        SET @start_time = GETDATE();
        PRINT('>> Truncating Table: silver.bss_service_plans')
        TRUNCATE TABLE silver.bss_service_plans;
        PRINT('>> Inserting Data Into: silver.bss_service_plans')
        INSERT INTO silver.bss_service_plans(
            plan_id,
            plan_sku,
            plan_name,
            monthly_charge,
            plan_cost,
            data_allowance_gb,
            plan_category_id
        )
        SELECT
            NULLIF(TRIM(UPPER(plan_id)), '') AS plan_id,
            NULLIF(TRIM(UPPER(plan_sku)), '') AS plan_sku,
            NULLIF(TRIM(plan_name), '') AS plan_name,
            TRY_CONVERT(DECIMAL(10,2), NULLIF(TRIM(monthly_charge), '')) AS monthly_charge,
            TRY_CONVERT(DECIMAL(10,2), NULLIF(TRIM(plan_cost), '')) AS plan_cost,
            TRY_CONVERT(INT, NULLIF(TRIM(data_allowance_gb), '')) AS data_allowance_gb,
            TRY_CONVERT(INT, NULLIF(TRIM(plan_category_id), '')) AS plan_category_id
        FROM bronze.bss_service_plans;

        SET @end_time = GETDATE();
        PRINT('>> Load duration: ') + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' ms';

        PRINT 'Loading OSS Tables';

        SET @start_time = GETDATE();
        PRINT('>> Truncating Table: silver.oss_customer_addresses')
        TRUNCATE TABLE silver.oss_customer_addresses;
        PRINT('>> Inserting Data Into: silver.oss_customer_addresses')
        INSERT INTO silver.oss_customer_addresses(
            customer_id,
            city,
            state_province,
            country
        )
        SELECT
            CASE
                WHEN LEFT(UPPER(TRIM(customer_id)), 4) = 'CUS-' AND LEN(TRIM(customer_id)) > 4 THEN UPPER(SUBSTRING(TRIM(customer_id), 5, LEN(TRIM(customer_id))))
                ELSE NULL
            END AS customer_id,
            NULLIF(TRIM(city), '') AS city,
            CASE UPPER(TRIM(state_province))
                WHEN 'FLORIDA' THEN 'FL'
                WHEN 'NEW YORK' THEN 'NY'
                WHEN 'CALIFORNIA' THEN 'CA'
                WHEN 'TEXAS' THEN 'TX'
                ELSE NULLIF(UPPER(TRIM(state_province)),'')
            END AS state_province,
            CASE UPPER(TRIM(country))
                WHEN 'USA' THEN 'US'
                WHEN 'UNITED STATES' THEN 'US'
                ELSE NULLIF(UPPER(TRIM(country)), '')
            END AS country
        FROM bronze.oss_customer_addresses;

        SET @end_time = GETDATE();
        PRINT('>> Load duration: ') + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' ms';

        SET @start_time = GETDATE();
        PRINT('>> Truncating Table: silver.oss_customer_demographics')
        TRUNCATE TABLE silver.oss_customer_demographics;
        PRINT('>> Inserting Data Into: silver.oss_customer_demographics')
        INSERT INTO silver.oss_customer_demographics(
            CID,
            BDATE,
            gender
        )
        SELECT
            NULLIF(UPPER(TRIM(CID)), '') AS CID,
            CASE
                WHEN TRIM(BDATE) LIKE '[0-9][0-9][0-9][0-9]-%'
                    THEN TRY_CONVERT(DATE, NULLIF(TRIM(BDATE), ''), 23)
                ELSE TRY_CONVERT(DATE, REPLACE(NULLIF(TRIM(BDATE), ''), '-', ' '), 106)
            END AS BDATE,
            CASE
                WHEN UPPER(TRIM(gender)) IN('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gender)) IN('M', 'MALE') THEN 'Male'
                ELSE NULL
            END AS gender
        FROM bronze.oss_customer_demographics;

        SET @end_time = GETDATE();
        PRINT('>> Load duration: ') + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' ms';

        SET @start_time = GETDATE();
        PRINT('>> Truncating Table: silver.oss_plan_categories')
        TRUNCATE TABLE silver.oss_plan_categories;
        PRINT('>> Inserting Data Into: silver.oss_plan_categories')
        INSERT INTO silver.oss_plan_categories(
            ID,
            CATEGORY,
            SUBCATEGORY,
            REQUIRES_CREDIT_CHECK
        )
        SELECT
            ID,
            CASE
                WHEN UPPER(TRIM(CATEGORY)) = 'POSTPAID' THEN 'Postpaid'
                WHEN UPPER(TRIM(CATEGORY)) = 'PREPAID' THEN 'Prepaid'
                WHEN UPPER(TRIM(CATEGORY)) = 'DATA-ONLY' THEN 'Data-Only'
                WHEN UPPER(TRIM(CATEGORY)) = 'BUSINESS' THEN 'Business'
                ELSE NULLIF(TRIM(CATEGORY), '')
            END AS CATEGORY,
            NULLIF(TRIM(SUBCATEGORY), '') AS SUBCATEGORY,
            CAST(
            CASE
                WHEN UPPER(TRIM(REQUIRES_CREDIT_CHECK)) IN ('Y', 'YES') THEN 1
                WHEN UPPER(TRIM(REQUIRES_CREDIT_CHECK)) IN ('N', 'NO') THEN 0
                ELSE NULL
            END AS BIT
                ) AS REQUIRES_CREDIT_CHECK
        FROM bronze.oss_plan_categories;

        SET @end_time = GETDATE();
        PRINT('>> Load duration: ') + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(20)) + ' ms';

        COMMIT TRANSACTION;
        SET @batch_end_time = GETDATE();
        PRINT 'Loading silver Layer is Completed';
        PRINT '>> Total Load Duration: '
            + CAST(DATEDIFF(MILLISECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(20)) + ' ms';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        PRINT 'ERROR OCCURRED DURING silver LAYER LOADING';
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Procedure: ' + COALESCE(ERROR_PROCEDURE(), 'Unknown');
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR(20));
        THROW;
    END CATCH
END;
GO



