-- ###############################################################
--  CREATE BRONZE LAYER TABLES
--  PROJECT: SNOWFLAKE DATA PIPELINE AND ANALYTICS PROJECT
--  DESCRIPTION:
--    THIS SCRIPT CREATES RAW INGESTION TABLES IN THE BRONZE SCHEMA
--    TO STORE CRM AND ERP SOURCE DATA AS-IS BEFORE TRANSFORMATION.
-- ###############################################################

-- WARNING:
-- THESE TABLES STORE RAW DATA DIRECTLY FROM SOURCE FILES.
-- DO NOT MODIFY OR TRANSFORM DATA AT THIS STAGE.

-- ###############################################################
--  CRM SOURCE TABLES
-- ###############################################################

CREATE OR REPLACE TABLE BRONZE.CRM_CUST_INFO (
    CST_ID              INT,
    CST_KEY             NVARCHAR(50),
    CST_FIRSTNAME       NVARCHAR(50),
    CST_LASTNAME        NVARCHAR(50),
    CST_MARITAL_STATUS  NVARCHAR(50),
    CST_GNDR            NVARCHAR(50),
    CST_CREATE_DATE     DATE
);

CREATE OR REPLACE TABLE BRONZE.CRM_PRD_INFO (
    PRD_ID       INT,
    PRD_KEY      NVARCHAR(50),
    PRD_NM       NVARCHAR(50),
    PRD_COST     INT,
    PRD_LINE     NVARCHAR(50),
    PRD_START_DT DATETIME,
    PRD_END_DT   DATETIME
);

CREATE OR REPLACE TABLE BRONZE.CRM_SALES_DETAILS (
    SLS_ORD_NUM  NVARCHAR(50),
    SLS_PRD_KEY  NVARCHAR(50),
    SLS_CUST_ID  INT,
    SLS_ORDER_DT INT,
    SLS_SHIP_DT  INT,
    SLS_DUE_DT   INT,
    SLS_SALES    INT,
    SLS_QUANTITY INT,
    SLS_PRICE    INT
);

-- ###############################################################
--  ERP SOURCE TABLES
-- ###############################################################

CREATE OR REPLACE TABLE BRONZE.ERP_LOC_A101 (
    CID    NVARCHAR(50),
    CNTRY  NVARCHAR(50)
);

CREATE OR REPLACE TABLE BRONZE.ERP_CUST_AZ12 (
    CID    NVARCHAR(50),
    BDATE  DATE,
    GEN    NVARCHAR(50)
);

CREATE OR REPLACE TABLE BRONZE.ERP_PX_CAT_G1V2 (
    ID           NVARCHAR(50),
    CAT          NVARCHAR(50),
    SUBCAT       NVARCHAR(50),
    MAINTENANCE  NVARCHAR(50)
);

-- ###############################################################
--  END OF SCRIPT
-- ###############################################################
