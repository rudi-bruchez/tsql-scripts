# Replication

Scripts for SQL Server transactional replication management.

## 📝 [deploy-subscribers-by-backup](./deploy-subscribers-by-backup.ps1)

PowerShell script to deploy multiple replication subscribers using backup initialization. Uses dbatools to backup the publisher, restore to subscribers, and set up replication. Backup initialization is preferred over snapshot for large databases.

## 📝 [monitor-replication-jobs](./monitor-replication-jobs.sql)

Monitors the status of replication jobs (Distribution, LogReader, Snapshot agents). Shows the last execution status, date/time, and error messages for each enabled replication job.

## Subdirectories

### 📁 [modules](./modules/)

PowerShell modules for replication management.
