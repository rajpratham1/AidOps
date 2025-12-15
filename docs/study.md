# 📚 Study Guide: What We Learned

This project was a crash course in **Modern cloud Data Engineering**. Here are the core topics you have mastered.

## 1. Snowflake Native Apps
**Concept**: "Bring the Application to the Data, not the Data to the Application."
*   **Old Way**: Download CSV -> Upload to AWS -> Run Python Script -> Upload results back.
*   **Our Way**: App runs *inside* Snowflake.
*   **Key Files**: `manifest.yml` (The Passport), `setup_script.sql` (The Blueprint).

## 2. Streamlit (The Interface)
**Concept**: "Python as a Frontend."
*   **What we learned**:
    *   `st.set_page_config()`: Layout setup.
    *   `st.tabs()`: Organizing complex views.
    *   `st.session_state`: The "Memory" of the app (remembering pages, local mode status).
    *   `st.data_editor()`: Editing database tables like an Excel sheet.

## 3. Snowpark (The Engine)
**Concept**: "DataFrames that run on SQL Server."
*   **Difference from Pandas**:
    *   Pandas runs on your laptop CPU.
    *   Snowpark runs on Snowflake's massive cluster.
*   **Key Command**: `session.write_pandas()`.
    *   *Real-World Use*: We used this to implement the "Upload CSV" feature, turning a Python DataFrame into a SQL Table instantly.

## 4. Environment Management (The Nightmare & The Solution)
**Concept**: "Dependency Hell."
*   **The Lesson**: Cloud platforms move fast. Python 3.8, 3.10, 3.12 availability fluctuates.
*   **The Master Strategy**: When in doubt, go **Minimal**.
    *   Removing strict version pins (e.g., just `pandas` instead of `pandas==2.0.1`) allows the platform's internal solver (Anaconda) to find its own compatible set. This was the breakthrough that fixed our deployment.

## 5. Security & Permissions
**Concept**: "Least Privilege Application Role."
*   **What we did**: Use `GRANT SELECT ON TABLE` instead of giving Admin access.
*   **Why**: If a hacker breaks the app, they can only see the app's table, not the whole company's data.

## 6. Generative AI (LLMs)
**Concept**: "Context-Aware Prompting."
*   **Technique**: RAG-lite (Retrieval Augmented Generation).
    1.  We calculated stats (Stock levels, Risks).
    2.  We turned those stats into a string (`context`).
    3.  We fed that context to `SNOWFLAKE.CORTEX.COMPLETE`.
*   *Result*: The AI wrote a specific email about *our* data, not a generic hallucination.
