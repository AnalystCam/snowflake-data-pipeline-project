-- ###############################################################
--  Snowflake Data Warehouse Setup Script
--  Project: Snowflake Data Pipeline & Analytics Project
--  Description:
--    This script initialises the database and schema layers
--    following the Medallion Architecture (Bronze → Silver → Gold).
-- ###############################################################

--  WARNING:
-- Running this script will REPLACE the database and schemas if they already exist.
-- All existing objects within these schemas (tables, views, etc.) will be lost.
-- Use with caution in production environments!

-- ###############################################################
-- Step 1: Create or replace the main database
-- ###############################################################
CREATE OR REPLACE DATABASE DATA_DB;

-- ###############################################################
-- Step 2: Create or replace schemas representing each data layer
-- ###############################################################
CREATE OR REPLACE SCHEMA DATA_DB.BRONZE;  
CREATE OR REPLACE SCHEMA DATA_DB.SILVER;  
CREATE OR REPLACE SCHEMA DATA_DB.GOLD;    

-- ###############################################################
-- End of Script
-- ###############################################################
