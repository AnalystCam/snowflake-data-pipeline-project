-- ###############################################################
-- SCRIPT NAME: SP_REFRESH_BRONZE_DATA.sql
-- PROJECT: SNOWFLAKE DATA PIPELINE AND ANALYTICS PROJECT
-- DESCRIPTION:
--   STORED PROCEDURE TO TRUNCATE AND RELOAD BRONZE TABLES
--   ONLY WHEN STAGE DATA HAS BEEN UPDATED.
-- ###############################################################

-- WARNING:
-- THIS PROCEDURE WILL REMOVE ALL EXISTING DATA FROM BRONZE TABLES
-- AND RELOAD FRESH DATA FROM THE STAGED CSV FILES IF NEW FILES EXIST.
-- EXECUTE CAREFULLY TO AVOID UNINTENDED DATA OVERWRITES.

CREATE OR REPLACE PROCEDURE DATA_DB.BRONZE.SP_REFRESH_BRONZE_DATA()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    v_message           STRING := '';
    v_latest_stage_time TIMESTAMP_NTZ;
    v_last_load_time    TIMESTAMP_NTZ;
BEGIN
    ------------------------------------------------------------------
    -- STEP 1: Retrieve latest file modification timestamp from stages
    ------------------------------------------------------------------
    SELECT MAX(LAST_MODIFIED) INTO :v_latest_stage_time
    FROM (
        SELECT LAST_MODIFIED FROM DIRECTORY(@DATA_DB.BRONZE.CRM_STAGE)
        UNION ALL
        SELECT LAST_MODIFIED FROM DIRECTORY(@DATA_DB.BRONZE.ERP_STAGE)
    );

    ------------------------------------------------------------------
    -- STEP 2: Get last successful load timestamp (from control table)
    ------------------------------------------------------------------
    CREATE OR REPLACE TABLE DATA_DB.BRONZE.ETL_CONTROL_LOG (
        PROCESS_NAME STRING,
        LAST_LOAD_TS  TIMESTAMP_NTZ
    );

    SELECT MAX(LAST_LOAD_TS)
    INTO :v_last_load_time
    FROM DATA_DB.BRONZE.ETL_CONTROL_LOG
    WHERE PROCESS_NAME = 'BRONZE_REFRESH';

    IF (v_last_load_time IS NULL OR v_latest_stage_time > v_last_load_time) THEN
        v_message := v_message || 'New or updated stage data detected. Refreshing Bronze tables...' || CHR(10);

        ------------------------------------------------------------------
        -- STEP 3: Truncate existing Bronze tables
        ------------------------------------------------------------------
        TRUNCATE TABLE DATA_DB.BRONZE.CRM_CUST_INFO;
        TRUNCATE TABLE DATA_DB.BRONZE.CRM_PRD_INFO;
        TRUNCATE TABLE DATA_DB.BRONZE.CRM_SALES_DETAILS;
        TRUNCATE TABLE DATA_DB.BRONZE.ERP_CUST_AZ12;
        TRUNCATE TABLE DATA_DB.BRONZE.ERP_LOC_A101;
        TRUNCATE TABLE DATA_DB.BRONZE.ERP_PX_CAT_G1V2;

        ------------------------------------------------------------------
        -- STEP 4: Reload data from Stages
        ------------------------------------------------------------------
        COPY INTO DATA_DB.BRONZE.CRM_CUST_INFO
        FROM @DATA_DB.BRONZE.CRM_STAGE/cust_info.csv
        FILE_FORMAT = (FORMAT_NAME = DATA_DB.BRONZE.CSV_FILE_FORMAT)
        ON_ERROR = 'CONTINUE';

        COPY INTO DATA_DB.BRONZE.CRM_PRD_INFO
        FROM @DATA_DB.BRONZE.CRM_STAGE/prd_info.csv
        FILE_FORMAT = (FORMAT_NAME = DATA_DB.BRONZE.CSV_FILE_FORMAT)
        ON_ERROR = 'CONTINUE';

        COPY INTO DATA_DB.BRONZE.CRM_SALES_DETAILS
        FROM @DATA_DB.BRONZE.CRM_STAGE/sales_details.csv
        FILE_FORMAT = (FORMAT_NAME = DATA_DB.BRONZE.CSV_FILE_FORMAT)
        ON_ERROR = 'CONTINUE';

        COPY INTO DATA_DB.BRONZE.ERP_CUST_AZ12
        FROM @DATA_DB.BRONZE.ERP_STAGE/cust_az12.csv
        FILE_FORMAT = (FORMAT_NAME = DATA_DB.BRONZE.CSV_FILE_FORMAT)
        ON_ERROR = 'CONTINUE';

        COPY INTO DATA_DB.BRONZE.ERP_LOC_A101
        FROM @DATA_DB.BRONZE.ERP_STAGE/loc_a101.csv
        FILE_FORMAT = (FORMAT_NAME = DATA_DB.BRONZE.CSV_FILE_FORMAT)
        ON_ERROR = 'CONTINUE';

        COPY INTO DATA_DB.BRONZE.ERP_PX_CAT_G1V2
        FROM @DATA_DB.BRONZE.ERP_STAGE/px_cat_g1v2.csv
        FILE_FORMAT = (FORMAT_NAME = DATA_DB.BRONZE.CSV_FILE_FORMAT)
        ON_ERROR = 'CONTINUE';

        ------------------------------------------------------------------
        -- STEP 5: Update ETL Control Log
        ------------------------------------------------------------------
        INSERT INTO DATA_DB.BRONZE.ETL_CONTROL_LOG
        VALUES ('BRONZE_REFRESH', CURRENT_TIMESTAMP());

        v_message := v_message || 'Bronze layer refreshed successfully at ' || CURRENT_TIMESTAMP() || CHR(10);
    ELSE
        v_message := v_message || 'No new files detected. Bronze layer not refreshed.' || CHR(10);
    END IF;

    RETURN v_message;

EXCEPTION
    WHEN OTHER THEN
        RETURN 'ERROR: ' || ERROR_MESSAGE();
END;
$$;

-- ###############################################################
-- EXECUTION TEST
-- ###############################################################
CALL DATA_DB.BRONZE.SP_REFRESH_BRONZE_DATA();
