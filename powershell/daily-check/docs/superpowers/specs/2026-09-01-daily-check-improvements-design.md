# Daily Check Script Improvements Design

## 1. Overview
The goal is to enhance the existing `daily-check.ps1` script to include SQL Server Agent Job history and status, focusing only on exceptions (errors, failures, or significant duration anomalies). Additionally, the script will be modernized to use idiomatic PowerShell, reduce technical debt, and support a `.env` file for configuration.

## 2. Configuration & `.env` Integration
- A `.env` file will be introduced to store environment-specific configurations and variables.
- A new helper function will parse the `.env` file and populate the script's environment.
- Variables to be moved/added to `.env`:
  - `EMAIL_FROM`
  - `EMAIL_TO`
  - `SMTP_SERVER`
  - `JOB_DURATION_THRESHOLD_PERCENT` (Default: 50)
  - `JOB_DURATION_THRESHOLD_MINUTES` (Default: 5)

## 3. SQL Agent Jobs Query Logic (Exceptions)
- A new T-SQL query will be executed against the `msdb` database for each instance.
- **Baseline Calculation:** The query will calculate a 30-day historical average duration for each job step. Note: The script will handle converting `msdb`'s native `HHMMSS` integer format into seconds for accurate math.
- **Filtering:** The query will look at job executions in the last 24 hours and return rows where:
  - `run_status` indicates Failure (0) or Cancellation (3).
  - **OR** the duration exceeds both thresholds simultaneously: `duration > (average * (1 + PERCENT_THRESHOLD/100))` **AND** `duration > (average + MINUTES_THRESHOLD)`.
- **Output Columns:** Server Name, Job Name, Step Name, Status, Run Date/Time, Actual Duration (formatted), Average Duration (formatted).

## 4. Code Modernization
- **Database Helper Function:** The verbose `System.Data.SqlClient` boilerplate will be abstracted into a reusable function: `Invoke-SQLQuery -ServerInstance $instance -Query $sql`.
- **Error Handling:** Basic `try/catch` blocks will be added around database connections and SMTP sending to ensure one offline server doesn't crash the entire script.
- **Idiomatic PowerShell:** Verbose `.NET` instantiations will be minimized, and the code will be structured to follow standard PowerShell best practices.

## 5. HTML Report Generation
- The script will gather data into two separate collections (`$dtHealth` and `$dtJobs`).
- The script will generate two distinct HTML fragments using `ConvertTo-Html -Fragment`:
  1. **Database Health Table** (Existing logic)
  2. **Job Exceptions Table** (New logic)
- These fragments will be assembled into a single HTML document using the existing `$reportstyle`.
- **Empty States:** If the Job Exceptions dataset is empty, the report will display a positive confirmation message (e.g., *"No job anomalies detected in the last 24 hours"*) instead of rendering an empty HTML table.
