# DBA Database

Scripts to create and configure a dedicated DBA maintenance database with Ola Hallengren's maintenance solution.

## 📝 [000.create-database](./000.create-database.sql)

Creates the _dba database with SIMPLE recovery model, restricted user access, and sets database scoped configuration for MAXDOP and query optimizer settings.

## 📝 [010.install-ola.ps1](./010.install-ola.ps1)

PowerShell script to install Ola Hallengren's SQL Server Maintenance Solution.

## 📝 [011.ola-calls](./011.ola-calls.sql)

Template calls to Ola Hallengren's maintenance solution procedures for full backups, transaction log backups, and index optimization with specific parameters.

## 📝 [012.ola-backups-ag](./012.ola-backups-ag.sql)

Configures Ola Hallengren backup procedures specifically for AlwaysOn Availability Group environments, handling AG and non-AG databases separately with copy-only backups for replicas.

## 📝 [015.rebuild_heaps](./015.rebuild_heaps.sql)

Stored procedure to identify and rebuild fragmented heaps across all online user databases, with support for AlwaysOn and database mirroring scenarios.

## 📝 [016.purge-msdb](./016.purge-msdb.sql)

Purges backup history, SQL Agent job history, and maintenance plan logs from msdb older than one month to keep the system database manageable.

## 📝 [020.sql-agent-jobs](./020.sql-agent-jobs.sql)

Sets up SQL Agent jobs for CommandLog Cleanup (daily) and Index/Statistics Maintenance with rebuild_heaps integration using Ola Hallengren procedures.

## 📝 [030.ola-check-log-for-errors](./030.ola-check-log-for-errors.sql)

Queries the _dba CommandLog table to display errors from Ola Hallengren maintenance procedures executed in the past day with error severity information.

## 📝 [030.ola-check-log-in-period](./030.ola-check-log-in-period.sql)

Reads the _dba CommandLog for maintenance operations within a specified time period and database, showing object names and performance metrics.
