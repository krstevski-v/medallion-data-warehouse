USE telco_dwh;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF SCHEMA_ID('gold') IS NULL
    EXEC('CREATE SCHEMA gold;');
GO

CREATE OR ALTER VIEW gold.dim_customer_accounts AS
SELECT
    a.account_id                                      AS customer_account_key,
    a.customer_key                                    AS customer_id,
    a.first_name                                      AS first_name,
    a.last_name                                       AS last_name,
    NULLIF(CONCAT_WS(' ', a.first_name, a.last_name), '') AS customer_name,
    a.email                                           AS email_address,
    a.join_date                                       AS account_start_date,
    a.contract_end_date                               AS contract_end_date,
    a.churn_status                                    AS is_churned,
    d.BDATE                                           AS date_of_birth,
    d.gender                                          AS gender,
    ad.city                                           AS city,
    ad.state_province                                 AS state_code,
    ad.country                                        AS country_code
FROM silver.bss_customer_accounts AS a
LEFT JOIN silver.oss_customer_demographics AS d
    ON d.CID = a.customer_key
LEFT JOIN silver.oss_customer_addresses AS ad
    ON ad.customer_id = a.customer_key;
GO

CREATE OR ALTER VIEW gold.dim_service_plans AS
SELECT
    p.plan_id                                         AS service_plan_key,
    p.plan_sku                                        AS plan_code,
    p.plan_name                                       AS plan_name,
    p.monthly_charge                                  AS monthly_list_price,
    p.plan_cost                                       AS listed_plan_cost,
    CASE
        WHEN p.data_allowance_gb >= 0 THEN p.data_allowance_gb
        ELSE NULL
    END                                               AS data_allowance_gb,
    CASE
        WHEN p.data_allowance_gb IS NULL THEN 'Missing'
        WHEN p.data_allowance_gb < 0 THEN 'Unresolved'
        ELSE 'Specified'
    END                                               AS allowance_status,
    p.plan_category_id                                AS plan_category_id,
    c.CATEGORY                                        AS plan_category,
    c.SUBCATEGORY                                     AS plan_subcategory,
    c.REQUIRES_CREDIT_CHECK                            AS requires_credit_check
FROM silver.bss_service_plans AS p
LEFT JOIN silver.oss_plan_categories AS c
    ON c.ID = p.plan_category_id;
GO

CREATE OR ALTER VIEW gold.fact_usage_billing AS
SELECT
    u.invoice_number                                  AS invoice_number,
    u.account_id                                      AS customer_account_key,
    p.plan_id                                         AS service_plan_key,
    u.billing_period_start                            AS billing_start_date,
    u.billing_period_end                              AS billing_end_date,
    DATEDIFF(DAY, u.billing_period_start, u.billing_period_end)
                                                      AS billing_period_days,
    u.data_usage_gb                                    AS data_used_gb,
    u.voice_minutes                                   AS voice_minutes_used,
    u.sms_count                                       AS sms_messages_sent,
    u.total_charge                                    AS billed_amount,
    CAST(CASE WHEN u.total_charge IS NULL THEN 1 ELSE 0 END AS BIT)
                                                      AS is_charge_missing
FROM silver.bss_monthly_usage AS u
LEFT JOIN silver.bss_service_plans AS p
    ON p.plan_sku = u.plan_sku;
GO
