# PowerShell

PowerShell scripts for SQL Server administration, automation, and auditing.

## 📝 [audit-privileges](./audit-privileges.ps1)

Retrieves all privileges for logins and users using SMO. Shows server role membership, database mappings, object permissions, and schema permissions. Requires the SqlServer module.

## 📝 [audit-privileges-per-database](./audit-privileges-per-database.ps1)

Audits privileges at the database level.

## 📝 [clean-errorlog](./clean-errorlog.ps1)

Cleans SQL Server ERRORLOG files by filtering out routine backup and CHECKDB success messages. Creates cleaned versions of log files with ".cleaned" extension for easier troubleshooting.

## 📝 [daily-check](./daily-check.ps1)

Daily health check script that queries multiple SQL Server instances for database information: owner, recovery mode, auto-shrink setting, growth type, state, last backup, and file location analysis. Generates HTML report and emails it.

## 📝 [eventlog-sqlagent](./eventlog-sqlagent.ps1)

Retrieves SQL Agent events from the Windows Application event log.

## 📝 [eventlog-sqlserver-errors](./eventlog-sqlserver-errors.ps1)

Retrieves the last 100 SQL Server error events from the Windows Application event log.

## 📝 [Export-Database-Scripts](./Export-Database-Scripts.ps1)

Exports all database objects (tables, stored procedures, views) to SQL script files using SMO. Creates a timestamped folder structure organized by database and object type. Includes indexes, triggers, permissions, and constraints.

## 📝 [export-system-procedures](./export-system-procedures.ps1)

Extracts all system stored procedure code from the master database using SMO. Useful for documentation or comparing system procedure definitions across versions.

## 📝 [generate-restore-sequence](./generate-restore-sequence.ps1)

Generates a RESTORE LOG sequence for all transaction log backups in a directory. Creates a restore.sql file with proper NORECOVERY options. Also shows dbatools alternative.

## 📝 [get-local-instances](./get-local-instances.ps1)

Detects all SQL Server instances installed on the local server by querying the Windows registry. Returns instance names and constructs proper connection strings.

## 📝 [list-sqlserver-services](./list-sqlserver-services.ps1)

Lists all SQL Server related Windows services showing name, display name, startup type, status, path, and service account.

## 📝 [run-bruteforceattack](./run-bruteforceattack.ps1)

Security testing script for authorized penetration testing purposes.

## 📝 [RunDatabaseBenchmark](./RunDatabaseBenchmark.ps1)

Simple database benchmark script that continuously executes random SQL scripts from a folder against a SQL Server database with configurable sleep intervals. Useful for workload simulation and performance testing.

## 📝 [server-audit](./server-audit.ps1)

Audits Windows server power settings. SQL Server best practice requires "High Performance" power scheme.

## 📝 [start-sqlagent](./start-sqlagent.ps1)

Starts the SQL Server Agent service.

## Subdirectories

### 📁 [modules](./modules/)

Reusable PowerShell modules for the scripts.
