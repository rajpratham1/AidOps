-- 5. The Setup Script (setup_script.sql)
-- Objective: initialize the app, create objects, and grant permissions.
-- Reference: This script is run by Snowflake when the consumer clicks "Install" (or CREATE APPLICATION).

-- 1. Create the Application Role
-- This role is granted to the consumer's role (e.g. ACCOUNTADMIN) so they can use the app.
CREATE APPLICATION ROLE IF NOT EXISTS app_public;

-- 2. Create the Schema
CREATE OR ALTER VERSIONED SCHEMA core;
GRANT USAGE ON SCHEMA core TO APPLICATION ROLE app_public;

-- 3. Register the Stored Procedure (The Logic)
-- We reference the Python file uploaded to the stage.
CREATE OR REPLACE PROCEDURE core.forecast_proc(
    input_table_name VARCHAR,
    date_col VARCHAR,
    item_col VARCHAR,
    qty_col VARCHAR
)
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('snowflake-snowpark-python')
IMPORTS = ('/src/forecast_logic.py') -- Path relative to app root
HANDLER = 'forecast_logic.main';

GRANT USAGE ON PROCEDURE core.forecast_proc(VARCHAR, VARCHAR, VARCHAR, VARCHAR) TO APPLICATION ROLE app_public;

-- 4. Create the Result Table (Empty initially)
-- This allows us to grant SELECT on it to the app role.
CREATE OR REPLACE TABLE core.FORECAST_RESULTS (
    DATE DATE,
    ITEM_NAME VARCHAR,
    QUANTITY_USED INTEGER,
    FORECAST_NEXT_7_DAYS FLOAT,
    STOCK_REMAINING INTEGER
);
GRANT SELECT ON TABLE core.FORECAST_RESULTS TO APPLICATION ROLE app_public;

GRANT SELECT ON TABLE core.FORECAST_RESULTS TO APPLICATION ROLE app_public;

-- 5. Register Reference Callback (Required for Manifest)
CREATE OR REPLACE PROCEDURE core.register_reference(ref_name STRING, operation STRING, ref_or_alias STRING)
RETURNS STRING
LANGUAGE SQL
AS $$
BEGIN
    CASE (operation)
        WHEN 'ADD' THEN
            SELECT SYSTEM$SET_REFERENCE(:ref_name, :ref_or_alias);
        WHEN 'REMOVE' THEN
            SELECT SYSTEM$REMOVE_REFERENCE(:ref_name, :ref_or_alias);
        WHEN 'CLEAR' THEN
            SELECT SYSTEM$REMOVE_REFERENCE(:ref_name);
    END CASE;
    RETURN 'Success';
END;
$$;
GRANT USAGE ON PROCEDURE core.register_reference(STRING, STRING, STRING) TO APPLICATION ROLE app_public;

-- 6. Register the Streamlit App (The UI)
CREATE OR REPLACE STREAMLIT core.ui_app
    FROM '/src' -- Directory containing the streamlit file
    MAIN_FILE = 'ui_app.py';

GRANT USAGE ON STREAMLIT core.ui_app TO APPLICATION ROLE app_public;
