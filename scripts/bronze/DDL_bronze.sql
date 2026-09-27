USE telco_dwh;

IF OBJECT_ID('bronze.bss_customer_accounts', 'U') IS NOT NULL
    DROP TABLE bronze.bss_customer_accounts;
GO
CREATE TABLE bronze.bss_customer_accounts (
    account_id NVARCHAR(100),
    customer_key NVARCHAR(100),
    first_name NVARCHAR(100),
    last_name NVARCHAR(100),
    email NVARCHAR(100),
    join_date NVARCHAR(100),
    contract_end_date NVARCHAR(100),
    churn_status NVARCHAR(50)
);

IF OBJECT_ID('bronze.bss_monthly_usage', 'U') IS NOT NULL
    DROP TABLE bronze.bss_monthly_usage;
GO
CREATE TABLE bronze.bss_monthly_usage (
    invoice_number NVARCHAR(100),
    account_id NVARCHAR(100),
    plan_sku NVARCHAR(100),
    billing_period_start NVARCHAR(100),
    billing_period_end NVARCHAR(100),
    data_usage_gb NVARCHAR(100),
    voice_minutes NVARCHAR(100),
    sms_count NVARCHAR(100),
    total_charge NVARCHAR(100)
);

IF OBJECT_ID('bronze.bss_service_plans', 'U') IS NOT NULL
    DROP TABLE bronze.bss_service_plans;
GO
CREATE TABLE bronze.bss_service_plans (
    plan_id NVARCHAR(100),
    plan_sku NVARCHAR(100),
    plan_name NVARCHAR(100),
    monthly_charge NVARCHAR(100),
    plan_cost NVARCHAR(100),
    data_allowance_gb NVARCHAR(100),
    plan_category_id NVARCHAR(100)
);

IF OBJECT_ID('bronze.oss_customer_addresses', 'U') IS NOT NULL
    DROP TABLE bronze.oss_customer_addresses;
GO
CREATE TABLE bronze.oss_customer_addresses (
    customer_id NVARCHAR(100),
    city NVARCHAR(100),
    state_province NVARCHAR(100),
    country NVARCHAR(100)
);

IF OBJECT_ID('bronze.oss_customer_demographics', 'U') IS NOT NULL
    DROP TABLE bronze.oss_customer_demographics;
GO
CREATE TABLE bronze.oss_customer_demographics (
    CID NVARCHAR(100),
    BDATE NVARCHAR(100),
    gender NVARCHAR(100)
);

IF OBJECT_ID('bronze.oss_plan_categories', 'U') IS NOT NULL
    DROP TABLE bronze.oss_plan_categories;
GO
CREATE TABLE bronze.oss_plan_categories(
    ID INT,
    CATEGORY NVARCHAR(100),
    SUBCATEGORY NVARCHAR(100),
    REQUIRES_CREDIT_CHECK NVARCHAR(100)
);


