# Daily Check SQL Scripts

SQL scripts used by the daily check monitoring process.

## 📝 [job-exceptions](./job-exceptions.sql)

T-SQL query executed against `msdb` to detect SQL Server Agent job failures, cancellations, and significant duration anomalies compared to a 30-day baseline.

## 📝 [database-health](./database-health.sql)

T-SQL query executed against `master` that returns one row per database file with the database owner, recovery model, auto-shrink and percent-growth settings, state, the last backup finish date (from `msdb.dbo.backupset`), the drive letter, and a flag that is set when a data file and a log file of the same database share the same drive.
