# 🛠️ Technical Documentation

## 1. Technology Stack
We used the **"Modern Snowflake Stack"** (Python-First approach).

| Component | Technology | Purpose |
| :--- | :--- | :--- |
| **Logic Core** | **Python 3.8** | The most stable runtime for Snowflake Native Apps. |
| **Interface** | **Streamlit** | Pure Python UI framework. No HTML/CSS/JS needed. |
| **Data Engine** | **Snowpark** | DataFrame API that pushes code *into* Snowflake (Zero Data Movement). |
| **Forecasting** | **3-Day Moving Avg** | Custom logic implemented in pure Python (Pandas/Snowpark). |
| **AI Layer** | **Cortex / Fallback** | Uses LLMs (Mistral/Gemma) for text generation, with smart fallback to Logic. |
| **Visuals** | **Plotly Express** | Interactive, high-performance charting. |

## 2. Code Structure
The project follows the official **Snowflake Native App** directory structure:

```text
rapid_relief_app/
├── manifest.yml              # The Passport: Tells Snowflake "I am an App"
├── setup_script.sql          # The Constructor: Builds schemas, tables, and permissions
├── src/
│   ├── ui_app.py            # The Frontend: Streamlit Interface + Business Logic
│   ├── forecast_logic.py     # The Backend: Pure Python calculation engine
│   └── environment.yml       # The Config: Dependency management (The "Magic Combination")
└── scripts/
    └── deploy_app.py         # The Robot: Automates the uploading and versioning
```

## 3. Key Technical Decisions

### A. The "Minimal 3.8" Strategy
**The Problem**: Snowflake's Anaconda package resolver is extremely strict. Requesting `Python 3.12` often causes conflicts with Streamlit.
**The Fix**: We mandated **Python 3.8** but removed strict version pinning for libraries like `pandas`.
*   *Why?* This lets Snowflake's internal solver pick the "Best available version" that works with 3.8, guaranteeing a successful build every time.

### B. The Internal Table Pattern (`FORECAST_RESULTS`)
**The Problem**: Installing an app usually creates an isolated sandbox. How do we get data in?
**The Solution**:
1.  Created `FORECAST_RESULTS` inside the `setup_script.sql`.
2.  Used `session.write_pandas(..."FORECAST_RESULTS")` in the UI to dump CSV data directly into the app's brain.
3.  This avoids complex "Consumer Grants" for simple demo use cases.

### C. Graceful AI Degradation
**The Problem**: Not all Snowflake Regions support Cortex AI (LLMs) yet.
**The Solution**: Wrapped the AI call in a `try/except` block.
*   *Primary*: Try `SNOWFLAKE.CORTEX.COMPLETE` (Real AI).
*   *Fallback*: If it fails (Error 002003), switch to a pre-calculated "Simulation Mode" so the app never crashes during a demo.

## 4. SQL Objects Created
*   `schema CORE`: The home for all app objects.
*   `procedure FORECAST_PROC`: The Python calculation engine wrapper.
*   `table FORECAST_RESULTS`: The central data store.
*   `streamlit UI_APP`: The user interface object.
