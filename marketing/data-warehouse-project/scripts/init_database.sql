/*
=============================================================
Create Database and Schemas in Snowflake
=============================================================
Script Purpose:
    Recreates the 'data_warehouse' database along with three schemas:
    'bronze', 'silver', and 'gold'. These follow the medallion architecture.
    
WARNING:
    This script uses CREATE OR REPLACE, which will drop the database if it exists.
    All objects inside will be permanently deleted. Use with caution.
=============================================================
*/

-- Step 1: Use the appropriate role
USE ROLE SYSADMIN;

-- Step 2: Create or replace a compute warehouse
CREATE OR REPLACE WAREHOUSE dw_wh
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

-- Step 3: Create or replace the database
CREATE OR REPLACE DATABASE data_warehouse
  COMMENT = 'Central database for medallion architecture: bronze, silver, gold';

-- Step 4: Set active database context
USE DATABASE data_warehouse;

-- Step 5: Create schemas for medallion data flow
CREATE OR REPLACE SCHEMA bronze
  COMMENT = 'Bronze schema: raw ingested data';

CREATE OR REPLACE SCHEMA silver
  COMMENT = 'Silver schema: cleansed and semi-transformed data';

CREATE OR REPLACE SCHEMA gold
  COMMENT = 'Gold schema: final analytical tables for ad-hoc SQL queries';