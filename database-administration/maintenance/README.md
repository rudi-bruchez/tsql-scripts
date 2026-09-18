# Maintenance

Database maintenance scripts for backups, heaps, and ongoing operations.

## 📝 [clean-old-backups](./clean-old-backups.sql)

Cleans up backup files older than a configurable number of days from a specified folder using xp_delete_file system procedure.

## 📝 [get-backups](./get-backups.sql)

Lists all backup history for the current database showing backup type, duration, sizes (compressed and uncompressed), LSNs, and recovery model.

## 📝 [rebuild-heaps-forwarded-records](./rebuild-heaps-forwarded-records.sql)

Rebuilds heaps of the current database having more than a given number of forwarded records, worst first. List-only mode, time limit, lock timeout per table, and a final error if any rebuild failed so a SQL Agent job reports it. For fragmentation/free-space based heap rebuilds across databases, see [015.rebuild_heaps](../dba-database/015.rebuild_heaps.sql).

## 📝 [running-agent-jobs](./running-agent-jobs.sql)

Displays currently executing SQL Agent jobs with start time and duration in minutes for real-time monitoring.

## 📝 [running-backups](./running-backups.sql)

Retrieves currently executing backup and restore operations with start time, duration, wait types, and completion percentage.

## 📝 [transaction-log-restore-performances](./transaction-log-restore-performances.sql)

Analyzes restore history showing backup size, restore dates, and duration between consecutive restore operations for performance analysis.
