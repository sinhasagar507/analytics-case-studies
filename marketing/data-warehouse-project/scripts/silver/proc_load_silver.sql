/* -----------------------------------------------------------------------------------
   Purpose:
     - Creates (or replaces) a stored procedure called silver.load_silver()
       implemented in JavaScript in Snowflake.
     - Automates the transformation and loading of data from Bronze layer tables
       into Silver layer tables in the Snowflake Data Warehouse.
     - Steps performed by this procedure:
         • Truncates Silver layer tables to ensure a clean slate for each load.
         • Transforms data from the Bronze layer, including:
             - Cleansing nulls or invalid values
             - Converting numeric date formats to DATE types
             - Standardizing code values to readable descriptions
             - Calculating missing or corrected measures
         • Loads transformed data into Silver layer tables via INSERT INTO.
         • Tracks execution times and logs progress messages in a return string.
     - Ensures data consistency and quality in the Silver layer, making it ready
       for further transformations and analytics in the Gold layer or downstream BI.

   Tables Loaded:
     - silver.crm_prd_info
         • Standardizes product line names
         • Calculates end dates for products
     - silver.crm_sales_details
         • Converts numeric dates to DATE
         • Calculates missing or invalid sales or price values
     - silver.erp_cust_az12
         • Cleans customer IDs
         • Fixes invalid birth dates
         • Standardizes gender codes
     - silver.erp_loc_a101
         • Standardizes country codes to readable names
         • Removes hyphens from customer IDs
     - silver.erp_px_cat_g1v2
         • Simple passthrough load

   Key Concepts:
     - The Silver layer reflects cleansed, harmonized data.
     - Data warehouse metadata columns like dwh_create_date are assumed to be
       automatically populated by table defaults defined in DDL scripts.
     - This procedure is meant to be called as part of a scheduled ELT pipeline.

   How to Run:
     1. Set your Snowflake session to the correct context:
        USE ROLE SYSADMIN;
        USE WAREHOUSE dw_wh;
        USE DATABASE data_warehouse;
        USE SCHEMA silver;

     2. Execute this script to create or replace the procedure.

     3. Run the procedure:
        CALL silver.load_silver();

   Output:
     - A multi-line string showing the outcome of each transformation step and
       total runtime for the Silver load.

----------------------------------------------------------------------------------- */

-- 1) Make sure your session is in the right context:
USE ROLE SYSADMIN;
USE WAREHOUSE dw_wh;
USE DATABASE data_warehouse;
USE SCHEMA silver;

CREATE OR REPLACE PROCEDURE silver.load_silver()
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
var startTime = new Date();
var stepStart, stepEnd, stepDuration;
var stmt, totalMessage = "";

function runStep(msg, sql) {
  stepStart = new Date();
  totalMessage += "\n=== " + msg + " ===";
  try {
    stmt = snowflake.createStatement({ sqlText: sql });
    stmt.execute();
    stepEnd = new Date();
    stepDuration = (stepEnd - stepStart) / 1000;
    totalMessage += "\n✔ Success in " + stepDuration + " sec.";
  } catch(err) {
    totalMessage += "\n✖ ERROR: " + err.message;
    throw err;
  }
}

// -------------------------------------------------------------
// crm_prd_info
// -------------------------------------------------------------
runStep("Truncate crm_prd_info", 
  `TRUNCATE TABLE IF EXISTS silver.crm_prd_info`
);

runStep("Load crm_prd_info", 
  `INSERT INTO silver.crm_prd_info (
     prd_id,cat_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_dt,prd_end_dt
   )
   SELECT
     prd_id,
     REPLACE(SUBSTRING(prd_key,1,5),'-','_'),
     SUBSTRING(prd_key,7),
     prd_nm,
     COALESCE(prd_cost,0),
     CASE UPPER(TRIM(prd_line))
       WHEN 'M' THEN 'Mountain'
       WHEN 'R' THEN 'Road'
       WHEN 'S' THEN 'Other Sales'
       WHEN 'T' THEN 'Touring'
       ELSE 'n/a'
     END,
     CAST(prd_start_dt AS DATE),
     CAST(DATEADD(day,-1,LEAD(prd_start_dt) OVER (
           PARTITION BY prd_key ORDER BY prd_start_dt
         )) AS DATE)
   FROM bronze.crm_prd_info`
);

// -------------------------------------------------------------
// crm_sales_details
// -------------------------------------------------------------
runStep("Truncate crm_sales_details", 
  `TRUNCATE TABLE IF EXISTS silver.crm_sales_details`
);

runStep("Load crm_sales_details", 
  `INSERT INTO silver.crm_sales_details (
     sls_ord_num,sls_prd_key,sls_cust_id,
     sls_order_dt,sls_ship_dt,sls_due_dt,
     sls_sales,sls_quantity,sls_price
   )
   SELECT
     sls_ord_num,
     sls_prd_key,
     sls_cust_id,
     CASE 
       WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt)!=8 THEN NULL
       ELSE TO_DATE(TO_VARCHAR(sls_order_dt),'YYYYMMDD')
     END,
     CASE 
       WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt)!=8 THEN NULL
       ELSE TO_DATE(TO_VARCHAR(sls_ship_dt),'YYYYMMDD')
     END,
     CASE 
       WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt)!=8 THEN NULL
       ELSE TO_DATE(TO_VARCHAR(sls_due_dt),'YYYYMMDD')
     END,
     CASE 
       WHEN sls_sales IS NULL OR sls_sales<=0 OR sls_sales!=sls_quantity*ABS(sls_price)
       THEN sls_quantity*ABS(sls_price)
       ELSE sls_sales
     END,
     sls_quantity,
     CASE 
       WHEN sls_price IS NULL OR sls_price<=0 
       THEN sls_sales/NULLIF(sls_quantity,0)
       ELSE ABS(sls_price)
     END
   FROM bronze.crm_sales_details`
);

// -------------------------------------------------------------
// erp_cust_az12
// -------------------------------------------------------------
runStep("Truncate erp_cust_az12", 
  `TRUNCATE TABLE IF EXISTS silver.erp_cust_az12`
);

runStep("Load erp_cust_az12", 
  `INSERT INTO silver.erp_cust_az12 (cid,bdate,gen)
   SELECT
     CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LENGTH(cid)) ELSE cid END,
     CASE WHEN bdate> CURRENT_DATE THEN NULL ELSE bdate END,
     CASE
       WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
       WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
       ELSE 'n/a'
     END
   FROM bronze.erp_cust_az12`
);

// -------------------------------------------------------------
// erp_loc_a101
// -------------------------------------------------------------
runStep("Truncate erp_loc_a101", 
  `TRUNCATE TABLE IF EXISTS silver.erp_loc_a101`
);

runStep("Load erp_loc_a101", 
  `INSERT INTO silver.erp_loc_a101 (cid,cntry)
   SELECT
     REPLACE(cid,'-',''),
     CASE
       WHEN TRIM(cntry)='DE' THEN 'Germany'
       WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
       WHEN TRIM(cntry)='' OR cntry IS NULL THEN 'n/a'
       ELSE TRIM(cntry)
     END
   FROM bronze.erp_loc_a101`
);

// -------------------------------------------------------------
// erp_px_cat_g1v2
// -------------------------------------------------------------
runStep("Truncate erp_px_cat_g1v2", 
  `TRUNCATE TABLE IF EXISTS silver.erp_px_cat_g1v2`
);

runStep("Load erp_px_cat_g1v2", 
  `INSERT INTO silver.erp_px_cat_g1v2(id,cat,subcat,maintenance)
   SELECT id,cat,subcat,maintenance
   FROM bronze.erp_px_cat_g1v2`
);

// -------------------------------------------------------------
// Finalize
// -------------------------------------------------------------
var totalDuration = (new Date() - startTime) / 1000;
totalMessage += "\n✅ Silver load completed in " + totalDuration + " seconds.";
return totalMessage;

$$;

-- Execute the STORED Procedure
CALL silver.load_silver();
