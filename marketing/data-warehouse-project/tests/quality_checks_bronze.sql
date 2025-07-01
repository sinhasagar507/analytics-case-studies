/* -----------------------------------------------------------------------------------
   Script: quality_checks_bronze.sql
   Purpose:
     - Performs data quality checks and basic data cleansing for tables in the 
       Bronze layer of the Snowflake Data Warehouse.
     - This script identifies and corrects:
         • Null or duplicate primary keys
         • Unwanted spaces in text fields
         • Inconsistent codes and values
         • Negative or invalid numeric values
         • Date anomalies and invalid date formats
     - Serves as both:
         1. A diagnostic tool to detect data quality issues in the raw data.
         2. A transformation layer applying fixes directly within SELECT queries
            to generate clean, standardized data for insertion into the Silver layer.

   Scope:
     - Runs against the following Bronze tables:
         • bronze.crm_cust_info
         • bronze.crm_prd_info
         • bronze.crm_sales_details
         • bronze.erp_cust_az12
         • bronze.erp_loc_a101
         • bronze.erp_px_cat_g1v2

   Key Tasks:
     - Checks for:
         • Duplicates or NULLs in primary keys
         • Inconsistent gender or marital status codes
         • Leading/trailing spaces in text fields
         • Negative or NULL numeric fields (e.g. costs, prices, sales)
         • Invalid or inconsistent dates
     - Standardizes data:
         • Converts codes to readable values (e.g. gender, country names)
         • Removes whitespace
         • Calculates derived values such as corrected sales amounts
         • Trims unwanted prefixes from IDs
     - Inserts cleansed data into Silver layer tables for downstream analytics.

   How to Use:
     1. Execute this script after the Bronze layer is loaded.
     2. Review SELECT outputs for any rows returned where "Expectation: No Results"
        is indicated in comments.
     3. Use provided INSERT INTO statements to load cleansed data into Silver tables.

   Notes:
     - This script combines exploratory analysis with transformation logic.
     - In production, transformations might be implemented in stored procedures
       or data pipelines rather than as ad-hoc queries.
----------------------------------------------------------------------------------- */

-- DATA_WAREHOUSE.PUBLIC
-- Activate your working context

-- Check for nulls or duplicates in the primary key
SELECT
    cst_id,
    COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id is NULL;

SELECT -- check for the different occurences of cst_id 29466 in bronze table, and select the entry with the ID 29466
* 
FROM 
bronze.crm_cust_info
WHERE cst_id = 29466; -- in such cases where these duplicates exist select the most updated date

SELECT 
* FROM
(SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info) AS t
WHERE t.flag_last=1 AND t.cst_id=29466;

-- Check for unwanted spaces 
SELECT cst_firstname 
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_lastname);

SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- Cleaning up the extra spaces 
SELECT
    cst_id,
    cst_key, 
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname, 
    -- cst_marital_status,
    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END cst_marital_status,
    -- cst_gndr,
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END cst_gndr,
    cst_create_date 
    FROM
    (
        SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    ) t WHERE flag_last=1 --here duplicates are being removed. Dates seem to be perfectly well-defined here. So no corrections needed for the dates

-- Data Standardization and Consistency
--- Expectation: No results
SELECT cst_key
FROM bronze.crm_cust_info
WHERE cst_key != TRIM(cst_key)

SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info


-- Finally insert the formatted data into the SILVER table
INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT
cst_id,
cst_key, 
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname, 
-- cst_marital_status,
CASE 
    WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
    WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
    ELSE 'n/a'
END cst_marital_status,
-- cst_gndr,
CASE 
    WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
    WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
    ELSE 'n/a'
END cst_gndr,
cst_create_date 
FROM
(
    SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) t WHERE flag_last=1; --here duplicates are being removed. Dates seem to be perfectly well-defined here. So no corrections needed for the dates

SELECT 
    prd_id,
    prd_key,
    

-- Customer Product Information
SELECT 
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
    prd_nm,
    IFNULL(prd_cost, 0),
    CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-INTERVAL '1 DAY' AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info
WHERE SUBSTRING(prd_key, 7, LEN(prd_key)) IN (
    SELECT sls_prd_key FROM bronze.crm_sales_details)

SELECT 
    prd_id, 
    prd_key,
    prd_nm, 
    prd_start_dt,
    LEAD(prd_start_dt) OVER (
        PARTITION BY prd_key 
        ORDER BY prd_start_dt
    ) - INTERVAL '1 DAY' AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');



-- Check for unwanted spaces
-- Expectation: No Results
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check for NULLS or Negative Numbers
-- Expectation: No Results
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Data Standardization and Consistency
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

-- Check for invalid AND invalid date orders
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt


-- Let's inspect the ERP table
SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2;

-- Customer Product Information final selection query
SELECT 
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
    prd_nm,
    IFNULL(prd_cost, 0),
    CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-INTERVAL '1 DAY' AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info
WHERE SUBSTRING(prd_key, 7, LEN(prd_key)) IN (
    SELECT sls_prd_key FROM bronze.crm_sales_details)

SELECT 
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
    prd_nm,
    IFNULL(prd_cost, 0),
    CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-INTERVAL '1 DAY' AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info

-- Check data consistency between: sales. quantity and price
-- >> Sales = Quantity * Price
-- >> Values must not be null, negative OR 0
SELECT DISTINCT
    sls_sales AS old_sls_sales,
    sls_quantity,
    sls_price as old_sls_price,
    CASE 
        WHEN sls_sales IS NULL 
            OR sls_sales <= 0 
            OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    CASE 
        WHEN sls_price IS NULL OR sls_price <= 0 
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE ABS(sls_price)
    END AS sls_price
FROM bronze.crm_sales_details;

-- Modified query
-- Check for the issue with each of the columns
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    
    -- Clean and convert sls_order_dt
    CASE 
        WHEN sls_order_dt = 0 
             OR LENGTH(sls_order_dt) != 8 THEN NULL
        ELSE TO_DATE(TO_VARCHAR(sls_order_dt), 'YYYYMMDD')
    END AS sls_order_dt,
    
    -- Clean and convert sls_ship_dt
    CASE 
        WHEN sls_ship_dt = 0 
             OR LENGTH(sls_ship_dt) != 8 THEN NULL
        ELSE TO_DATE(TO_VARCHAR(sls_ship_dt), 'YYYYMMDD')
    END AS sls_ship_dt,
    
    -- Clean and convert sls_due_dt
    CASE 
        WHEN sls_due_dt = 0 
             OR LENGTH(sls_due_dt) != 8 THEN NULL
        ELSE TO_DATE(TO_VARCHAR(sls_due_dt), 'YYYYMMDD')
    END AS sls_due_dt,

    -- Clean up the extraction of sales data
    CASE 
        WHEN sls_sales IS NULL 
            OR sls_sales <= 0 
            OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    
    sls_quantity,
    
    CASE 
        WHEN sls_price IS NULL OR sls_price <= 0 
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE ABS(sls_price)
    END AS sls_price
FROM bronze.crm_sales_details;

-- Check for a new table
SELECT
    cid,
    bdate,
    gen
FROM bronze.erp_cust_az12;

-- Find customers matching the pattern
SELECT
    cid,
    bdate,
    gen
FROM bronze.erp_cust_az12
WHERE cid LIKE '%AW00011000%';

SELECT
    cid,
    CASE 
        WHEN cid LIKE 'NAS%' 
        THEN SUBSTRING(cid, 4, LENGTH(cid))
        ELSE cid
    END AS cid_trimmed,
    bdate,
    gen
FROM bronze.erp_cust_az12;

-- Check if there is any mismatch in joining the tables
SELECT
    cid AS original_cid,
    CASE 
        WHEN cid LIKE 'NAS%' 
        THEN SUBSTRING(cid, 4, LENGTH(cid))
        ELSE cid
    END AS transformed_cid,
    bdate,
    gen
FROM bronze.erp_cust_az12
WHERE CASE 
          WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
          ELSE cid
      END NOT IN (
          SELECT DISTINCT cst_key
          FROM silver.crm_cust_info
      );

-- Remove and reverify
SELECT
    CASE 
        WHEN cid LIKE 'NAS%' 
        THEN SUBSTRING(cid, 4, LENGTH(cid))
        ELSE cid
    END AS cid_trimmed,
    bdate,
    gen
FROM bronze.erp_cust_az12;


-- Check if the current date is even possible
SELECT
    CASE 
        WHEN cid LIKE 'NAS%' 
        THEN SUBSTRING(cid, 4, LENGTH(cid))
        ELSE cid
    END AS cid,
    
    CASE 
        WHEN bdate > CURRENT_DATE THEN NULL
        ELSE bdate
    END AS bdate,
    CASE 
        WHEN UPPER(TRIM(gen)) in ('F','FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) in ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12;

-- Check for data standardization and consistency
SELECT DISTINCT
    gen,
    CASE 
        WHEN UPPER(TRIM(gen)) in ('F','FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) in ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12;

SELECT 
    REPLACE(cid, '-', '') cid,
CASE 
    WHEN TRIM(cntry)='DE' THEN 'Germany'
    WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
    WHEN TRIM(cntry)='' OR cntry IS NULL THEN 'n/a'
    ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101;

--Data Standardization and Consistency
SELECT 
    DISTINCT cntry AS old_cntry,
    CASE 
        WHEN TRIM(cntry)='DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry)='' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101
ORDER BY cntry

-- Check for erp_px_cat_g1v2
-- Bronze table quality issues
-- Really nothing to be transformed in this table as of now
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat)

-- Check for data standardization and consistency in this table
SELECT 
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT 
       subcat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT 
       maintenance
FROM bronze.erp_px_cat_g1v2;