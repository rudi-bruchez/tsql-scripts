# Replication

Scripts for SQL Server transactional replication management.

## 📝 [deploy-subscribers-by-backup](./deploy-subscribers-by-backup.ps1)

PowerShell script to deploy multiple replication subscribers using backup initialization. Uses dbatools to backup the publisher, restore to subscribers, and set up replication. Backup initialization is preferred over snapshot for large databases. Set the publication name in `$Publication` and define `$FileMapping` (logical file name to physical path on the subscribers) before running: the script stops after the backup until `$FileMapping` is defined.

## 📝 [monitor-replication-jobs](./monitor-replication-jobs.sql)

Monitors the status of replication jobs (Distribution, LogReader, Snapshot agents). Shows the last execution status, date/time, and error messages for each enabled replication job.

## Subdirectories

### 📁 [modules](./modules/)

PowerShell modules for replication management.
