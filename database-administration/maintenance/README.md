# Maintenance

Database maintenance scripts for backups, heaps, and ongoing operations.

## 📝 [clean-old-backups](./clean-old-backups.sql)

Cleans up backup files older than a configurable number of days from a specified folder using xp_delete_file system procedure.

## 📝 [get-backups](./get-backups.sql)

Lists all backup history for the current database showing backup type, duration, sizes (compressed and uncompressed), LSNs, and recovery model.

## 📝 [rebuild-heaps](./rebuild-heaps.sql)

Comprehensive stored procedure to identify fragmented heaps across databases and generate/execute ALTER TABLE REBUILD commands based on fragmentation thresholds.

## 📝 [running-agent-jobs](./running-agent-jobs.sql)

Displays currently executing SQL Agent jobs with start time and duration in minutes for real-time monitoring.

## 📝 [running-backups](./running-backups.sql)

Retrieves currently executing backup and restore operations with start time, duration, wait types, and completion percentage.

## 📝 [transaction-log-restore-performances](./transaction-log-restore-performances.sql)

Analyzes restore history showing backup size, restore dates, and duration between consecutive restore operations for performance analysis.
