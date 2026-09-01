# Daily Check SQL Scripts

SQL scripts used by the daily check monitoring process.

## 📝 [job-exceptions](./job-exceptions.sql)

T-SQL query executed against `msdb` to detect SQL Server Agent job failures, cancellations, and significant duration anomalies compared to a 30-day baseline.
