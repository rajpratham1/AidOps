import os
import sys
import toml
from snowflake.snowpark import Session

# --- CONFIGURATION ---
APP_PACKAGE_NAME = "AID_OPS_PACKAGE"
APP_NAME = "AID_OPS_APP"
SCHEMA_NAME = "CODE_SCHEMA"
STAGE_NAME = "APP_STAGE"

def get_session():
    # 1. Resolve secrets path
    current_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.join(current_dir, "..")
    secrets_path = os.path.join(project_root, ".streamlit", "secrets.toml")
    
    if not os.path.exists(secrets_path):
        print(f"❌ Error: Secrets file not found at: {secrets_path}")
        print("Please ensure you have configured .streamlit/secrets.toml")
        sys.exit(1)
        
    # 2. Load Secrets
    try:
        data = toml.load(secrets_path)
        if "snowflake" in data:
            creds = data["snowflake"]
        else:
            print("❌ Error: [snowflake] section not found in secrets.toml")
            sys.exit(1)
            
        print("🔑 Connecting to Snowflake...")
        session = Session.builder.configs(creds).create()
        return session, project_root
    except Exception as e:
        print(f"❌ Connection Failed: {e}")
        sys.exit(1)

def deploy():
    session, root_dir = get_session()
    
    try:
        # 1. Create Application Package
        print(f"📦 Creating Package: {APP_PACKAGE_NAME}...")
        session.sql(f"CREATE APPLICATION PACKAGE IF NOT EXISTS {APP_PACKAGE_NAME}").collect()
        session.sql(f"USE APPLICATION PACKAGE {APP_PACKAGE_NAME}").collect()
        
        # 2. Create Schema & Stage
        print(f"🏗️  Creating Stage: {SCHEMA_NAME}.{STAGE_NAME}...")
        session.sql(f"CREATE SCHEMA IF NOT EXISTS {SCHEMA_NAME}").collect()
        session.sql(f"CREATE STAGE IF NOT EXISTS {SCHEMA_NAME}.{STAGE_NAME}").collect() # Internal stage
        
        stage_path = f"@{APP_PACKAGE_NAME}.{SCHEMA_NAME}.{STAGE_NAME}"

        # 3. Upload Files
        print("js🚀 Uploading Artifacts...")
        
        # Helper to upload
        def upload(local_path, stage_subchk):
            # Windows path fix? Snowpark handles it usually, but we ensure / separators for stage
            print(f"   -> Uploading {os.path.basename(local_path)}")
            session.file.put(
                local_path, 
                f"{stage_path}/{stage_subchk}", 
                auto_compress=False, 
                overwrite=True
            )

        # Root files
        for f in ["manifest.yml", "setup_script.sql", "requirements.txt"]:
            p = os.path.join(root_dir, f)
            if os.path.exists(p):
                upload(p, "")
            else:
                print(f"⚠️ Warning: {f} missing!")
        
        # Src files
        src_dir = os.path.join(root_dir, "src")
        if os.path.exists(src_dir):
            for f in os.listdir(src_dir):
                if f.endswith(".py") or f.endswith(".css") or f.endswith(".yml"): # Filter for code/assets
                    p = os.path.join(src_dir, f)
                    upload(p, "src")
        
        # 4. Create App
        print(f"🚀 Launching Application: {APP_NAME}...")
        # Drop old version to ensure clean slate (Dev Mode)
        session.sql(f"DROP APPLICATION IF EXISTS {APP_NAME}").collect()
        
        # Create new
        session.sql(f"""
            CREATE APPLICATION {APP_NAME}
            FROM APPLICATION PACKAGE {APP_PACKAGE_NAME}
            USING '{stage_path}'
        """).collect()
        
        print(f"""
✅ DEPLOYMENT SUCCESSFUL!
--------------------------------------------------
Application Name: {APP_NAME}
Package Name:     {APP_PACKAGE_NAME}

👉 Go to Snowsight > Data Products > Apps to launch it.
--------------------------------------------------
""")

    except Exception as e:
        print(f"❌ Deployment Failed: {e}")
    finally:
        session.close()

if __name__ == "__main__":
    deploy()
