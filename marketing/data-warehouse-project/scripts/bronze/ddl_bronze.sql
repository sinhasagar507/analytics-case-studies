/* -----------------------------------------------------------------------------------
   Purpose:
     - Creates (or replaces) the tables in the Bronze layer of the Snowflake 
       Data Warehouse.
     - Defines the schema for raw, ingested data from both CRM and ERP systems.
     - All tables are created in the schema:
         data_warehouse.bronze
   Tables Created:
     - crm_cust_info
         Raw customer records from CRM
     - crm_prd_info
         Raw product master data from CRM
     - crm_sales_details
         Raw transactional sales data from CRM
     - erp_loc_a101
         Raw location data from ERP
     - erp_cust_az12
         Raw customer demographic data from ERP
     - erp_px_cat_g1v2
         Raw product price category master data from ERP
   Notes:
     - Tables are designed to capture raw, untransformed data as staged files
       are loaded into the warehouse.
     - No primary keys or constraints are defined at this stage.
     - Column data types reflect raw data formats as delivered in source CSVs.
     - Some fields (e.g. sls_order_dt) are stored as NUMBER, suggesting potential
       future conversion to DATE depending on business rules.
   How to Run:
     1. Set your role, warehouse, database, and schema context.
     2. Execute this script to create all Bronze tables.
----------------------------------------------------------------------------------- */

-- DATA_WAREHOUSE.PUBLIC

-- Activate your working context
USE ROLE SYSADMIN;
USE WAREHOUSE dw_wh;
USE DATABASE data_warehouse;
USE SCHEMA bronze;

-- Recreate bronze tables
CREATE OR REPLACE TABLE crm_cust_info (
    cst_id              NUMBER,
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_marital_status  VARCHAR(50),
    cst_gndr            VARCHAR(50),
    cst_create_date     DATE
)
COMMENT = 'Raw customer info from CRM system';

CREATE OR REPLACE TABLE crm_prd_info (
    prd_id       NUMBER,
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     NUMBER,
    prd_line     VARCHAR(50),
    prd_start_dt TIMESTAMP_NTZ,
    prd_end_dt   TIMESTAMP_NTZ
)
COMMENT = 'Raw product info from CRM product master';

CREATE OR REPLACE TABLE crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  NUMBER,
    sls_order_dt NUMBER,   -- Consider converting to DATE if possible
    sls_ship_dt  NUMBER,
    sls_due_dt   NUMBER,
    sls_sales    NUMBER,
    sls_quantity NUMBER,
    sls_price    NUMBER
)
COMMENT = 'Raw sales transactional data from CRM system';

CREATE OR REPLACE TABLE erp_loc_a101 (
    cid    VARCHAR(50),
    cntry  VARCHAR(50)
)
COMMENT = 'Raw ERP location data';

CREATE OR REPLACE TABLE erp_cust_az12 (
    cid    VARCHAR(50),
    bdate  DATE,
    gen    VARCHAR(50)
)
COMMENT = 'Raw ERP customer demographics';

CREATE OR REPLACE TABLE erp_px_cat_g1v2 (
    id           VARCHAR(50),
    cat          VARCHAR(50),
    subcat       VARCHAR(50),
    maintenance  VARCHAR(50)
)
COMMENT = 'Raw ERP price category master data';