# 🔌 API Connection & Architecture Guide

## 1. The Dual-Connection Architecture
AidOps is built with a unique **"Hybrid Connectivity"** engine. This allows the same code to run on your laptop (Local Mode) and inside the Snowflake Cloud (Native App Mode) without changing a single line.

### A. How it Works (`ui_app.py`)
The function `get_snowflake_session()` is the brain behind this:

1.  **Cloud Priority**: It first checks `snowflake.snowpark.context.get_active_session()`.
    *   If running in Snowflake, this succeeds immediately.
    *   *Security Benefit*: No passwords are ever stored or needed in the cloud.
2.  **Local Fallback**: If step 1 fails, it looks for a local `.streamlit/secrets.toml` file.
    *   If found, it creates a secure tunnel using your credentials.
    *   *Dev Benefit*: You can code locally while querying live data.

```python
# The Core Logic
def get_snowflake_session():
    # 1. Cloud Mode (Native App)
    try:
        return get_active_session()
    except:
        pass 
    
    # 2. Local Mode (Dev)
    return Session.builder.configs(st.secrets["snowflake"]).create()
```

## 2. API Security & Permissions
The Snowflake Native App Framework uses a **"Least Privilege"** API model.

### A. Application Role (`app_public`)
Instead of giving the app full Admin rights, we created a specific role in `setup_script.sql`:
*   `CREATE APPLICATION ROLE app_public;`
*   The app can **only** do what this role allows.

### B. What We Granted
*   `USAGE ON SCHEMA core`: Allows app to see the folder.
*   `USAGE ON STREAMLIT ui_app`: Allows app to launch the interface.
*   `SELECT ON TABLE FORECAST_RESULTS`: Allows app to read/write its own data.
*   *Crucially*: The app **cannot** see your other tables (Payroll, Customer Data) unless you explicitly `GRANT REFERENCE` to it.

## 3. Data Flow API
1.  **Upload**: User -> Streamlit UI -> `session.write_pandas()` -> `FORECAST_RESULTS` Table.
2.  **Processing**: Python Stored Proc (`forecast_proc`) -> Reads Table -> Snowpark DataFrame -> Calculates Forecast -> Writes Back.
3.  **Visualization**: Streamlit -> `session.table()` -> Pandas DataFrame -> Plotly Charts.

## 4. Troubleshooting Connections
*   **"No Secrets Found"**: You are in the cloud (Good!). The app was trying to find a local file. We fixed this by catching the `FileNotFoundError`.
*   **"Database Not Found"**: You tried to write to a local database name (`RAPID_RELIEF_DB`) while inside the app. We fixed this by writing to the internal context reference (`FORECAST_RESULTS`).
