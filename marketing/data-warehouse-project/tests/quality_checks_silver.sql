/* -----------------------------------------------------------------------------------
   Script: quality_checks_silver.sql
   Purpose:
     - Performs data quality checks on tables in the Silver layer of the Snowflake 
       Data Warehouse.
     - Verifies that data transformations from the Bronze layer have:
         • Removed duplicates and null primary keys
         • Eliminated unwanted whitespace
         • Corrected inconsistent codes or descriptions
         • Fixed invalid or impossible date values
         • Ensured numerical consistency (e.g. sales calculations)
     - Identifies any data issues that may still exist post-transformation, 
       helping ensure the Silver layer is clean and ready for use by the Gold layer 
       or business reporting tools.

   Scope:
     - Runs quality checks across the following Silver tables:
         • silver.crm_cust_info
         • silver.crm_prd_info
         • silver.crm_sales_details
         • silver.erp_cust_az12
         • silver.erp_loc_a101

   Key Tasks:
     - Checks for:
         • Duplicates or NULLs in primary keys
         • Leading/trailing spaces in text fields
         • Invalid or impossible date values
         • Data consistency between related tables
         • Logical inconsistencies (e.g. sales != quantity × price)
     - Highlights rows that may require manual investigation or further cleansing.

   How to Use:
     1. Run this script after the Silver layer is loaded.
     2. Review query results:
         • Queries with comments like "Expectation: No Results" should return zero rows.
         • If rows are returned, further action may be required to cleanse data.
     3. Optionally adjust INSERT/UPDATE logic in ETL jobs to correct the issues.

   Notes:
     - This script includes some queries referencing Bronze tables, for cross-layer 
       data quality validation.
     - In production, many of these checks might be incorporated into automated
       data quality pipelines or monitoring dashboards.
----------------------------------------------------------------------------------- */

-- DATA_WAREHOUSE.PUBLIC
-- Activate your working context
USE ROLE SYSADMIN;
USE WAREHOUSE dw_wh;
USE DATABASE data_warehouse;


-- CRM_Customer_Info table
-- Check for nulls or duplicates in the primary key. Expectations(no results)
SELECT
    cst_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id is NULL;

-- Check for unwanted spaces. Expectation: No results. 
SELECT cst_firstname 
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Check for unwanted spaces. Expectation: No results.
SELECT cst_lastname 
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Data Standardization and Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

-- Check the data 
SELECT * FROM silver.crm_cust_info;

-- CRM_prd_info table
-- Check for duplicate keys OR null values
SELECT 
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*)>1 OR prd_id IS NULL;

-- Check for unwanted spaces

-- Check quality issues of bronze layer's CRM_Sales_details
SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_due_dt, 
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

-- Check for any INVALID dates
SELECT 
    sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0;

-- Replace all dates with the value <= 0 to NULL
SELECT
    NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0;

-- Check for bad date lengths
SELECT
    NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
    OR LENGTH(sls_order_dt) != 8
    OR sls_order_dt > 20500101
    OR sls_order_dt < 19000101;

SELECT
    NULLIF(sls_ship_dt, 0) AS sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0
    OR LENGTH(sls_ship_dt) != 8
    OR sls_ship_dt > 20500101
    OR sls_ship_dt < 19000101;

-- Check for Invalid date orders
SELECT 
* 
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

SELECT 
* 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Check for discrepancies in sales or sales price
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
    OR sls_sales IS NULL
    OR sls_quantity IS NULL
    OR sls_price IS NULL
    OR sls_sales <= 0
    OR sls_quantity <= 0
    OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- Do a final check
SELECT * FROM silver.crm_sales_details;

-- erp_cust_az12 table
-- Identify Out-of-Range Dates
SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > CURRENT_DATE;

-- Data Standardization & Consistency
SELECT DISTINCT
    gen
FROM silver.erp_cust_az12;

-- View entire table
SELECT *
FROM silver.erp_cust_az12;

-- Also check the other data formats
SELECT cst_key FROM silver.crm_cust_info;

-- Check for mismatched IDs between ERP locations and CRM customer keys
SELECT
    REPLACE(cid, '-', '') AS cid,
    cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (
    SELECT cst_key
    FROM silver.crm_cust_info
);

-- A final look at 'erp_loc_a101' table
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

SELECT * FROM silver.erp_loc_a101;
