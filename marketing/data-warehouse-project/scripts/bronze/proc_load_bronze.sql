/* -----------------------------------------------------------------------------------
   Purpose:
     - This script creates (or replaces) a Snowflake stored procedure called 
       bronze.load_bronze(), implemented in JavaScript.
     - It automates the loading of CSV files from a Snowflake stage into tables 
       in the Bronze layer of a data warehouse.
     - It performs the following:
         • Defines a CSV file format if not already existing.
         • Truncates Bronze tables to ensure fresh loads.
         • Loads data from staged CSV files into Bronze tables using COPY INTO.
         • Logs row counts after each load step into a debug log table.
         • Captures timing for each step and the overall run time.
         • Returns a summary string indicating how many rows were loaded into 
           each table, plus total duration.
     - Implements error handling:
         • Logs errors to the bronze.load_debug_log table.
         • Returns an error message if any load step fails.
   Context:
     - Used in the ELT process of a Snowflake Data Warehouse architecture,
       typically part of the Bronze layer in a multi-layer architecture 
       (Bronze → Silver → Gold).
     - Supports operational monitoring through runtime logging.
   Prerequisites:
     - Snowflake stage @BRONZE must exist and contain the listed CSV files:
         • cust_info.csv
         • prd_info.csv
         • sales_details.csv
         • CUST_AZ12.csv
         • LOC_A101.csv
         • PX_CAT_G1V2.csv
     - Tables in the bronze schema:
         • bronze.crm_cust_info
         • bronze.crm_prd_info
         • bronze.crm_sales_details
         • bronze.ERP_CUST_AZ12
         • bronze.ERP_LOC_A101
         • bronze.ERP_PX_CAT_G1V2
     - Debug logging table bronze.load_debug_log must exist.
   How to Run:
     1. Execute this script to create the procedure.
     2. Invoke the procedure:
          CALL bronze.load_bronze();
----------------------------------------------------------------------------------- */

USE ROLE SYSADMIN;
USE WAREHOUSE dw_wh;
USE DATABASE data_warehouse;
USE SCHEMA bronze;

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
var startTime = new Date();
var stepStart, stepEnd, stepDuration;
var stmt, rs;
var cntCust, cntPrd, cntSales, cntErpCust, cntErpLoc, cntErpCat;
var log = "";

// helper to run a single SQL statement and log timing
function runStep(msg, sql) {
  log += "\n=== " + msg + " ===";
  stepStart = new Date();
  try {
    stmt = snowflake.createStatement({ sqlText: sql });
    rs = stmt.execute();
    stepEnd = new Date();
    stepDuration = ((stepEnd - stepStart) / 1000).toFixed(2);
    log += "\n✔ Success (" + stepDuration + "s)";
  } catch(err) {
    log += "\n✖ ERROR: " + err.message;
    throw err;
  }
}

try {
  // 0) start
  runStep("START Bronze Load", 
    `INSERT INTO bronze.load_debug_log(message) 
     VALUES('[START] Loading Bronze Layer')`
  );

  // 1) file format
  runStep("Define file format",
    `CREATE OR REPLACE FILE FORMAT bronze_csv_ff 
       TYPE = 'CSV'
       FIELD_OPTIONALLY_ENCLOSED_BY = '"' 
       SKIP_HEADER = 1 
       FIELD_DELIMITER = ',' 
       ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE`
  );

  // 2) crm_cust_info
  runStep("Truncate crm_cust_info", 
    `TRUNCATE TABLE bronze.crm_cust_info`
  );
  runStep("Load crm_cust_info", 
    `COPY INTO bronze.crm_cust_info 
       FROM @BRONZE/cust_info.csv 
       FILE_FORMAT = bronze_csv_ff`
  );
  rs = snowflake.createStatement({sqlText:`SELECT COUNT(*) FROM bronze.crm_cust_info`}).execute(); 
  rs.next(); cntCust = rs.getColumnValue(1);
  runStep("Log crm_cust_info count", 
    `INSERT INTO bronze.load_debug_log(message) 
     VALUES('crm_cust_info loaded: ${cntCust} rows')`
  );

  // 3) crm_prd_info
  runStep("Truncate crm_prd_info", 
    `TRUNCATE TABLE bronze.crm_prd_info`
  );
  runStep("Load crm_prd_info", 
    `COPY INTO bronze.crm_prd_info 
       FROM @BRONZE/prd_info.csv 
       FILE_FORMAT = bronze_csv_ff`
  );
  rs = snowflake.createStatement({sqlText:`SELECT COUNT(*) FROM bronze.crm_prd_info`}).execute();
  rs.next(); cntPrd = rs.getColumnValue(1);
  runStep("Log crm_prd_info count", 
    `INSERT INTO bronze.load_debug_log(message) 
     VALUES('crm_prd_info loaded: ${cntPrd} rows')`
  );

  // 4) crm_sales_details
  runStep("Truncate crm_sales_details", 
    `TRUNCATE TABLE bronze.crm_sales_details`
  );
  runStep("Load crm_sales_details", 
    `COPY INTO bronze.crm_sales_details 
       FROM @BRONZE/sales_details.csv 
       FILE_FORMAT = bronze_csv_ff`
  );
  rs = snowflake.createStatement({sqlText:`SELECT COUNT(*) FROM bronze.crm_sales_details`}).execute();
  rs.next(); cntSales = rs.getColumnValue(1);
  runStep("Log crm_sales_details count", 
    `INSERT INTO bronze.load_debug_log(message) 
     VALUES('crm_sales_details loaded: ${cntSales} rows')`
  );

  // 5) ERP_CUST_AZ12
  runStep("Truncate ERP_CUST_AZ12", 
    `TRUNCATE TABLE bronze.ERP_CUST_AZ12`
  );
  runStep("Load ERP_CUST_AZ12", 
    `COPY INTO bronze.ERP_CUST_AZ12 
       FROM @BRONZE/CUST_AZ12.csv 
       FILE_FORMAT = bronze_csv_ff`
  );
  rs = snowflake.createStatement({sqlText:`SELECT COUNT(*) FROM bronze.ERP_CUST_AZ12`}).execute();
  rs.next(); cntErpCust = rs.getColumnValue(1);
  runStep("Log ERP_CUST_AZ12 count", 
    `INSERT INTO bronze.load_debug_log(message) 
     VALUES('ERP_CUST_AZ12 loaded: ${cntErpCust} rows')`
  );

  // 6) ERP_LOC_A101
  runStep("Truncate ERP_LOC_A101", 
    `TRUNCATE TABLE bronze.ERP_LOC_A101`
  );
  runStep("Load ERP_LOC_A101", 
    `COPY INTO bronze.ERP_LOC_A101 
       FROM @BRONZE/LOC_A101.csv 
       FILE_FORMAT = bronze_csv_ff`
  );
  rs = snowflake.createStatement({sqlText:`SELECT COUNT(*) FROM bronze.ERP_LOC_A101`}).execute();
  rs.next(); cntErpLoc = rs.getColumnValue(1);
  runStep("Log ERP_LOC_A101 count", 
    `INSERT INTO bronze.load_debug_log(message) 
     VALUES('ERP_LOC_A101 loaded: ${cntErpLoc} rows')`
  );

  // 7) ERP_PX_CAT_G1V2
  runStep("Truncate ERP_PX_CAT_G1V2", 
    `TRUNCATE TABLE bronze.ERP_PX_CAT_G1V2`
  );
  runStep("Load ERP_PX_CAT_G1V2", 
    `COPY INTO bronze.ERP_PX_CAT_G1V2 
       FROM @BRONZE/PX_CAT_G1V2.csv 
       FILE_FORMAT = bronze_csv_ff`
  );
  rs = snowflake.createStatement({sqlText:`SELECT COUNT(*) FROM bronze.ERP_PX_CAT_G1V2`}).execute();
  rs.next(); cntErpCat = rs.getColumnValue(1);
  runStep("Log ERP_PX_CAT_G1V2 count", 
    `INSERT INTO bronze.load_debug_log(message) 
     VALUES('ERP_PX_CAT_G1V2 loaded: ${cntErpCat} rows')`
  );

  // final end message
  runStep("END Bronze Load", 
    `INSERT INTO bronze.load_debug_log(message) 
     VALUES('[END] Bronze Layer Load Completed')`
  );

  // total duration
  var totalSec = ((new Date() - startTime) / 1000).toFixed(2);
  runStep("Log total duration", 
    `INSERT INTO bronze.load_debug_log(message) 
     VALUES('Total Bronze load time: ${totalSec} seconds')`
  );

  return `LOAD COMPLETE | CRM_CUST_INFO=${cntCust} | CRM_PRD_INFO=${cntPrd} | CRM_SALES=${cntSales} | ERP_CUST=${cntErpCust} | ERP_LOC=${cntErpLoc} | ERP_CAT=${cntErpCat} | DURATION=${totalSec}s`;

} catch(err) {
  // catch & log unexpected errors
  try {
    snowflake.createStatement({
      sqlText: `INSERT INTO bronze.load_debug_log(message)
                  VALUES('ERROR during Bronze load: ${err.message}')`
    }).execute();
  } catch(_) { /* swallow logging‐failures */ }
  return `ERROR during Bronze load: ${err.message}`;
}
$$;

-- finally, to invoke it:
CALL bronze.load_bronze();