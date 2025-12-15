# 👥 Team Onboarding Guide: How to Add Users

This guide explains exactly how to add your teammates or hackathon judges to your Snowflake account so they can view the live **AidOps** app.

---

## 🛑 Designing the Strategy
Since we deployed in "Developer Mode" (unversioned), the app is private to your account.
**The Strategy**: We will create a "Guest User" inside your account for your teammates.

---

## 🛠️ Step 1: Create the User (The Access Pass)

1.  **Log in** to your Snowflake account (the one you are using right now).
2.  Switch to the **ACCOUNTADMIN** role (Click your name in the bottom left -> Roles -> Account Admin).
3.  In the Left Sidebar, navigate to **Admin** -> **Users & Roles**.
4.  Click the **Users** tab.
5.  Click the blue **+ User** button in the top right.

### 📝 Fill in these details exactly:
*   **User Name**: `TEAM_MEMBER_1` (No spaces, uppercase is safer).
*   **First Name**: (Their Name, e.g., "Sarah").
*   **Last Name**: (Their Last Name).
*   **Password**: Create a *shared* team password (e.g., `AidOps_Hackathon_2025!`).
    *   *Tip*: Uncheck "Force password change on first login" to make it easier for them.
*   **Confirm Password**: `AidOps_Hackathon_2025!`
*   **Display Name**: `Teammate: Sarah`
*   **Default Role**: Select **ACCOUNTADMIN** (This is critical for Hackathons—it ensures they see exactly what you see without permission errors).

6.  Click **Create User**.

*(Repeat this step for each teammate).*

---

## 🔗 Step 2: Get Your Account URL ( The "Door")

Your teammates need to know *where* to log in.
1.  Look at your browser URL bar right now.
2.  It looks something like this:
    `https://app.snowflake.com/onshlzc/yv05307/...`
3.  **Your Account URL** is the part before the `#`.
    *   Example: `https://app.snowflake.com/onshlzc/yv05307`

---

## 📧 Step 3: Send the Invite (Copy-Paste This)

Send this message to your team (Slack/Discord/Email):

> **Subject: Login Details for AidOps (Snowflake)**
>
> Hey Team! 🚀
>
> I have deployed the AidOps App. Here is how to access the live dashboard:
>
> **1. The Login Page**
> Go here: [INSERT_YOUR_ACCOUNT_URL_HERE]
> *(Example: https://app.snowflake.com/onshlzc/yv05307)*
>
> **2. Your Credentials**
> *   **Username**: `TEAM_MEMBER_1`
> *   **Password**: `AidOps_Hackathon_2025!`
>
> **3. Launch the App**
> Once you are logged in:
> 1.  Click **Data Products** (in the left sidebar).
> 2.  Click **Apps**.
> 3.  Click **AID_OPS_APP**.
>
> *Note: If you see a "No Data" screen, go to the "Connect Data" tab and I'll walk you through loading the sample file.*

---

## ❓ Common Questions

**Q: Why give them ACCOUNTADMIN?**
A: In a real enterprise, you wouldn't. But for a Hackathon, you want to avoid "Permission Denied" errors during a demo. This is the "God Mode" role that guarantees access.

**Q: Can they look at my code?**
A: Yes. If they go to the "Snowsight Worksheets" tab, they can verify the code existence. This is often good for judges effectively auditing your work.
