USE telco_dwh;

IF OBJECT_ID('silver.bss_customer_accounts', 'U') IS NOT NULL
    DROP TABLE silver.bss_customer_accounts;
GO
CREATE TABLE silver.bss_customer_accounts (
    account_id INT,
    customer_key NVARCHAR(100),
    first_name NVARCHAR(100),
    last_name NVARCHAR(100),
    email NVARCHAR(100),
    join_date DATE,
    contract_end_date DATE,
    churn_status BIT
);

IF OBJECT_ID('silver.bss_monthly_usage', 'U') IS NOT NULL
    DROP TABLE silver.bss_monthly_usage;
GO
CREATE TABLE silver.bss_monthly_usage (
    invoice_number NVARCHAR(100),
    account_id INT,
    plan_sku NVARCHAR(100),
    billing_period_start DATE,
    billing_period_end DATE,
    data_usage_gb DECIMAL(10,2),
    voice_minutes INT,
    sms_count INT,
    total_charge DECIMAL(10,2)
);

IF OBJECT_ID('silver.bss_service_plans', 'U') IS NOT NULL
    DROP TABLE silver.bss_service_plans;
GO
CREATE TABLE silver.bss_service_plans (
    plan_id NVARCHAR(100),
    plan_sku NVARCHAR(100),
    plan_name NVARCHAR(100),
    monthly_charge DECIMAL(10,2),
    plan_cost DECIMAL(10,2),
    data_allowance_gb INT,
    plan_category_id INT
);

IF OBJECT_ID('silver.oss_customer_addresses', 'U') IS NOT NULL
    DROP TABLE silver.oss_customer_addresses;
GO
CREATE TABLE silver.oss_customer_addresses (
    customer_id NVARCHAR(100),
    city NVARCHAR(100),
    state_province NVARCHAR(100),
    country NVARCHAR(100)
);

IF OBJECT_ID('silver.oss_customer_demographics', 'U') IS NOT NULL
    DROP TABLE silver.oss_customer_demographics;
GO
CREATE TABLE silver.oss_customer_demographics (
    CID NVARCHAR(100),
    BDATE DATE,
    gender NVARCHAR(100)
);

IF OBJECT_ID('silver.oss_plan_categories', 'U') IS NOT NULL
    DROP TABLE silver.oss_plan_categories;
GO
CREATE TABLE silver.oss_plan_categories(
    ID INT,
    CATEGORY NVARCHAR(100),
    SUBCATEGORY NVARCHAR(100),
    REQUIRES_CREDIT_CHECK BIT
);


