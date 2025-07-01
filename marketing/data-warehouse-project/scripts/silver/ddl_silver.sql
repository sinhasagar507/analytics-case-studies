/* -----------------------------------------------------------------------------------
   Purpose:
     - Creates (or replaces) the tables in the Silver layer of the Snowflake 
       Data Warehouse.
     - Defines the schema for cleansed and standardized data from CRM and ERP systems.
     - All tables are created in the schema:
         data_warehouse.silver
     - Intended for downstream transformations into business-ready Gold views.
   Tables Created:
     - crm_cust_info
         Cleaned CRM customer data
     - crm_prd_info
         Cleaned CRM product master data
     - crm_sales_details
         Cleaned CRM transactional sales data
     - erp_loc_a101
         Cleaned ERP location data
     - erp_cust_az12
         Cleaned ERP customer demographic data
     - erp_px_cat_g1v2
         Cleaned ERP product price category master data
   Notes:
     - Tables are designed for further transformation in the Silver-to-Gold pipeline.
     - Default values are set for dwh_create_date to capture load time.
     - Any additional cleansing or enrichment logic can be applied in ELT processes.
   How to Run:
     1. Set your role, warehouse, database, and schema context.
     2. Execute this script to create all Silver tables.
----------------------------------------------------------------------------------- */

-- DATA_WAREHOUSE.PUBLIC

-- Activate your working context
USE ROLE SYSADMIN;
USE WAREHOUSE dw_wh;
USE DATABASE data_warehouse;
USE SCHEMA silver;

-- Recreate silver tables
CREATE OR REPLACE TABLE crm_cust_info (
    cst_id              NUMBER,
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_marital_status  VARCHAR(50),
    cst_gndr            VARCHAR(50), -- all of these columns have the prefix "cst", which means they come from the source system
    cst_create_date     DATE,
    dwh_create_date     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() -- metadata column created by the data engineer
)
COMMENT = 'Cleaned customer info from CRM system';

-- Drop table if it exists
DROP TABLE IF EXISTS silver.crm_prd_info;

-- Create the table
CREATE TABLE silver.crm_prd_info (
    prd_id           NUMBER,
    cat_id           VARCHAR(50),
    prd_key          VARCHAR(50),
    prd_nm           VARCHAR(50),
    prd_cost         NUMBER,
    prd_line         VARCHAR(50),
    prd_start_dt     DATE,
    prd_end_dt       DATE,
    dwh_create_date  TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Cleaned product info from CRM product master';

CREATE OR REPLACE TABLE crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt DATE,   -- converted from NUMBER to DATE in Silver layer
    sls_ship_dt  DATE,
    sls_due_dt   DATE,
    sls_sales    NUMBER,
    sls_quantity NUMBER,
    sls_price    NUMBER,
    dwh_create_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Cleaned sales transactional data from CRM system';

CREATE OR REPLACE TABLE erp_loc_a101 (
    cid    VARCHAR(50),
    cntry  VARCHAR(50),
    dwh_create_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Cleaned ERP location data';

CREATE OR REPLACE TABLE erp_cust_az12 (
    cid    VARCHAR(50),
    bdate  DATE,
    gen    VARCHAR(50),
    dwh_create_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Cleaned ERP customer demographics';

CREATE OR REPLACE TABLE erp_px_cat_g1v2 (
    id           VARCHAR(50),
    cat          VARCHAR(50),
    subcat       VARCHAR(50),
    maintenance  VARCHAR(50),
    dwh_create_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Cleaned ERP price category master data';