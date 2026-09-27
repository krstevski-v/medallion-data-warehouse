# Telecom Data Warehouse

A local SQL Server warehouse that combines telecom customer, plan, and billing data into a model for analytical queries and Power BI. The project focuses on data ingestion, data cleaning, data quality, SQL transformations, dimensional modeling, and Python automation.

**Tools:** SQL Server, T-SQL, Python, and Power BI.

## Source data

The project uses a synthetic dataset which represents two source systems and includes missing values, inconsistent formats, and conflicting attributes.

| Source system | Data used in this project |
| --- | --- |
| BSS - Business Support System | Customer accounts and churn status, monthly usage and invoice charges, and service plans with prices and allowances. |
| OSS - Operations Support System | Customer addresses, demographics, and plan categories with credit-check requirements. |

The six CSV files are stored in `data/source_bss` and `data/source_oss`. These are simulated source assignments, not extracts from real telecom systems.

## Medallion architecture

Medallion architecture organizes data into progressively refined layers: **Bronze → Silver → Gold**. Each layer has a separate schema in the local `telco_dwh` database.

| Layer | Implementation |
| --- | --- |
| Bronze | Loads the source CSVs into staging tables using `BULK INSERT`, preserving raw values for cleaning. Each run truncates and reloads the tables. |
| Silver | Trims text, standardizes customer keys and categorical values, converts dates and numbers, and handles missing or invalid values. All six tables are refreshed within one transaction. |
| Gold | Combines Silver tables into customer-account and service-plan dimensions and a billing/usage fact view with one row per invoice. Columns use business-friendly names. |

Gold views read the refreshed Silver data directly. 

## Power BI report

The [report](power_bi/overview_report.pbix) provides a one-page overview of billed amounts, accounts, invoices, and data usage, with monthly, state, and plan-category breakdowns. It demonstrates how the Gold model can support reporting; the main focus of this project is the engineering pipeline.

![Billing and usage overview](power_bi/report_image.png)

## How to run

Prerequisites: a local SQL Server instance, Python 3, and `sqlcmd` available on your PATH. The runner uses Windows authentication and Python's standard library. SQL Server must have permission to read the project's `data` folder.

1. For initial setup, execute these scripts in order using SQL Server Management Studio or `sqlcmd`:
   - `scripts/init_db.sql`
   - `scripts/bronze/DDL_bronze.sql`
   - `scripts/silver/DDL_silver.sql`

   **Setup recreates the database and tables. Run it only when initializing or intentionally resetting the warehouse.**

2. Set `SERVER` in `run_warehouse.py` to your SQL Server instance. The default is `.\SQLEXPRESS`; the SQL scripts use the database name `telco_dwh`.

3. From the project directory, run:

   ```powershell
   python run_warehouse.py
   ```

   The runner deploys both procedures, loads Bronze and then Silver, and creates or updates the Gold views. It resolves the data path relative to its own location and stops if a SQL command fails. Use this same command for subsequent full refreshes.

4. Open `power_bi/overview_report.pbix` in Power BI Desktop, update the SQL Server connection if needed, and refresh the report.
