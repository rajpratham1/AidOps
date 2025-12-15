# 2. The Logic Layer (Snowpark Python)
# Objective: Clean data (fill nulls) and calculate a 7-day Moving Average forecast.
# Architecture: Separated into a pure Python function for modularity and easier testing.
# This file will be referenced by the Snowflake Stored Procedure.

import snowflake.snowpark.functions as F
from snowflake.snowpark.window import Window

def calculate_forecast(session, input_table_name, date_col, item_col, qty_col):
    """
    Reads data from the input table, fills nulls in quantity with 0,
    and calculates a 7-day moving average to forecast the next 7 days.
    """
    # 1. Read the input table (Dynamic reference provided by the app)
    df = session.table(input_table_name)

    # 2. Data Cleaning: Fill NULL quantity with 0 (assuming null means no usage)
    df_clean = df.na.fill({qty_col: 0})

    # 3. Forecast Logic: 7-Day Moving Average
    # We partition by Item to forecast per item history.
    # Rows between 6 preceding and current row covers 7 days.
    window_spec = Window.partition_by(item_col).order_by(date_col).rows_between(-6, 0)
    
    df_forecast = df_clean.with_column(
        "FORECAST_NEXT_7_DAYS", 
        F.avg(F.col(qty_col)).over(window_spec)
    )

    # 4. Return the result
    # In a real app, we might write this to a result table. 
    # Here, we return the dataframe for the Stored Proc to handle (e.g., return query ID or data).
    return df_forecast

# The Stored Procedure Entry Point
def main(session, input_table_name, date_col, item_col, qty_col):
    # Call the logic function
    result_df = calculate_forecast(session, input_table_name, date_col, item_col, qty_col)
    
    # Materialize the result to a temporary table for the UI to query efficiently
    # The UI will read from this 'RESULT_CACHE' table.
    result_table_name = "FORECAST_RESULTS"
    result_df.write.mode("overwrite").save_as_table(result_table_name)
    
    # CRITICAL: save_as_table("overwrite") drops and recreates the table, losing the initial grants.
    # We must re-grant SELECT to the application role so the Streamlit app can read it.
    session.sql(f"GRANT SELECT ON TABLE {result_table_name} TO APPLICATION ROLE app_public").collect()
    
    return f"Success: Forecast generated in {result_table_name}"
