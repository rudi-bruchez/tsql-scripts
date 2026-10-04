# AGENTS.md

Guide for language models and coding agents that use this repository to answer SQL Server questions: which script answers which need, what a script changes on the server, and what to check before running it.

The repository is a library of standalone T-SQL and PowerShell scripts for SQL Server administration and diagnostics (SQL Server 2014 and later, Azure SQL Database, Azure SQL Managed Instance, AWS RDS). There is no build, no installer and no test suite: a script is opened, adapted and run in SSMS, Azure Data Studio, `sqlcmd` or `Invoke-Sqlcmd`. Every folder has a `README.md` that describes each of its scripts; read it before picking a script. Conventions for writing new scripts are in `CLAUDE.md`.

## Before running a script

1. Read the script header and the folder README entry. They name the parameters to edit: variables at the top (`@table_name`, `@database_name`, `@when`, `@Execute`), placeholders in angle brackets (`<database>`, `<login>`, `<PROCEDURE NAME>`), hard-coded object names, file paths, server names.
2. Check the nature of the script in the section below. Most scripts only read DMVs and catalog views. Those that change something are listed; never run one of them on a user's server without saying what it will do and getting an explicit go.
3. Check the scope. Many scripts work on the current database only: connect to the right database (or add a `USE`) first. Others cover the whole instance or loop over all databases.
4. Check the version and platform. Scripts under `cloud/azure/azure-sql-database/` and `extended-events/azure-sql-database/` only run on Azure SQL Database; `hadr/` needs an availability group; some scripts need a recent version (`sys.dm_db_page_info` 2019+, Query Store 2016+, Query Store hints 2022+, `timestamp_utc` in XE files 2017+, `TRIM` 2017+).
5. Check permissions. Diagnostic queries need `VIEW SERVER STATE` (or `VIEW DATABASE STATE` for database-scoped DMVs, `VIEW SERVER PERFORMANCE STATE` on 2022+). `diagnostics/permissions-for-diagnostics.sql` creates a server role with these permissions, which is itself a change to the server.
6. Run diagnostic queries as shipped: they set `READ UNCOMMITTED` and end with `OPTION (RECOMPILE, MAXDOP 1)` so they stay light on a busy server. Scripts that scan every page (`index-physical-stats-detailed.sql`, the compression estimates) are expensive on large databases: restrict them to one table when possible.

## Nature of the scripts

A script is read-only unless it appears in one of the lists below.

### Scripts that only generate commands

They return DDL or commands as text in a result column and execute nothing. The output must be reviewed before anyone runs it.

- `database-administration/ddl-generation/`: every script except `drop-database-users.sql` and `remove-files.sql` (see the next list).
- `database-administration/configuration/recovery-simple.sql`
- `database-information/compression/uncompressed-objects.sql` (REBUILD with compression)
- `database-information/indexes/fragmentation-analysis.sql`, `normalize-index-names.sql`
- `database-information/statistics/drop-duplicate-stats.sql`, `statistics.sql`, `user-created-statistics.sql`
- `database-information/tables-information/search-columns-by-name.sql`
- `index-management/missing-indexes.sql`, `unused-indexes.sql` (CREATE and DROP INDEX statements)
- `diagnostics/query-store/query-hints-set.sql`
- `security/list-and-generate-roles.sql`, `list-and-generate-role-members.sql`, `list-logins.sql` (the latter outputs password hashes, or a `<password>` placeholder with `@withPassword = 0`)

### Scripts that change the server or a database when run

- `database-administration/clear-proc-in-cache.sql`: evicts one plan from the cache.
- `database-administration/remove-useless-schemas.sql`: drops the legacy `db_*` schemas.
- `database-administration/configuration/set-instance-dop.sql`: changes MAXDOP and cost threshold when `@execute = 1`.
- `database-administration/ddl-generation/drop-database-users.sql`: lists the `DROP USER` statements by default and executes them with `@execute = 1`.
- `database-administration/ddl-generation/remove-files.sql`: empties (`DBCC SHRINKFILE ... EMPTYFILE`) and removes database files unless `@debug = 1`.
- `database-administration/maintenance/clean-old-backups.sql` (deletes backup files with `xp_delete_file`), `rebuild-heaps-forwarded-records.sql` (rebuilds by default, `@Execute = 1`).
- `database-administration/sqlagent/add-notification-to-all-jobs.sql`, `disable-all-jobs.sql`, `increase-agent-history.sql`.
- `database-administration/dba-database/011.ola-calls.sql`, `012.ola-backups-ag.sql`, `016.purge-msdb.sql`: backups, index maintenance, CHECKDB and history purge when run as a whole.
- `cloud/azure/backup-to-blob-storage.sql`: alters a credential and takes a backup.
- `diagnostics/permissions-for-diagnostics.sql`: creates a server role and grants permissions.
- `diagnostics/execution/running-plans-using-ligthweight-profile.sql`: enables trace flag 7412 globally before querying.
- `diagnostics/query-store/activate-query-store.sql`: enables the Query Store.
- `diagnostics/wait-statistics/reinitialize-stats.sql`: clears the wait statistics of the instance.
- `diagnostics/locking/monitor-blocking.sql` and `hadr/maintenance/alert-on-lost-connection-with-secondary.sql`: send mail through Database Mail.
- `extended-events/on-prem/blocked-processes-create.sql`: sets `blocked process threshold`; `blocked-processes-cleanup.sql` resets it and drops the session.
- `extended-events/on-prem/management/delete-event-files.sql`: enables `xp_cmdshell` for a moment and deletes `.xel` files.
- `server-information/remove-telemetry.sql`: alters the telemetry XE session.
- `service-broker/clean-receive-queue.sql`, `drop-routes.sql`: receive and end conversations, drop routes.
- PowerShell: `replication/deploy-subscribers-by-backup.ps1` (backup, restore, subscriptions), `powershell/generate-restore-sequence.ps1` (can restore), `powershell/start-sqlagent.ps1`, `powershell/RunDatabaseBenchmark.ps1`, `powershell/daily-check/daily-check.ps1` (sends mail, writes logs), `powershell/run-bruteforceattack.ps1` (password attack against `sa`, for authorized testing only).

### Scripts that install objects

- Extended Events sessions: every `*-create.sql` under `extended-events/` and `hadr/` creates a session, and most start it. The lines that stop or drop a session are commented out, with a note on when to run them.
- Procedures in `stored-procedures/`: most are installed in `master` as `sp_` procedures so they can be called from any database; `RebuildHeaps.sql` and `ConvertLobToMax.sql` install in the current database and modify data when called with `@Execute = 1`.
- Functions in `functions/` (in `master`, except `fn_tableSize` in the current database), `hadr/functions/`, and `math/` (schema `math` in the current database, installed in the order given by its README).
- `security/block-by-logon-trigger.sql`: a server logon trigger that refuses every connection not in its allow list, sysadmins and SQL Agent included. Edit the allowed hosts first; recovery goes through the DAC.
- `diagnostics/locking/vBlockingGraph.sql` (a view), `monitoring/monitor-long-transactions.sql`, `monitoring/queries-for-dashboards/transaction-logs.sql`, `database-administration/alerts/` (Agent alerts), `cloud/aws/rds/create-alwayson-xevent.sql`.
- `database-administration/dba-database/`: creates the `_dba` database, installs Ola Hallengren's MaintenanceSolution and the Agent jobs. Run the files in the order of their numeric prefix.

## Script for a need

Paths are relative to the repository root. The README of each folder lists further variants.

### Activity and performance right now

| Need | Script |
|---|---|
| What is running now | `diagnostics/execution/running-requests-short.sql`, `running-requests-detailed.sql`, or `sp_whoisactive.sql` if `sp_WhoIsActive` is installed |
| Who blocks whom | `diagnostics/locking/analyze-blocked-sessions.sql`, `stored-procedures/sp_WhoIsBlocking.sql` |
| What is locked | `diagnostics/locking/what-is-locked.sql` |
| Recent deadlocks | `diagnostics/locking/get-deadlock-from-xevents.sql` (system_health session) |
| Open transactions and their log use | `diagnostics/execution/active-transactions.sql` |
| Progress of a backup, restore, DBCC or shrink | `diagnostics/execution/running-admin-operations.sql`, `monitoring/current-dbcc-operations.sql`, `monitoring/shrink-monitoring.sql` |
| Where the server spends its waits | `diagnostics/wait-statistics/waits-statistics.sql` |
| Memory grants and memory pressure | `diagnostics/Memory/memory-analysis.sql`, `memory-grants.sql`, `resource-semaphore.sql` |
| tempdb space and version store | `diagnostics/tempdb/tempdb-space-usage.sql`, `version-store-usage.sql` |
| IO latency per file | `diagnostics/IO/dm_io_virtual_file_stats.sql` |

### Query history and plans

| Need | Script |
|---|---|
| Heaviest queries in the plan cache | `diagnostics/execution-stats/query_stats.sql` |
| Most executed procedures | `diagnostics/execution-stats/stored-procedures/procedures-by-execution-count.sql` |
| Queries that were slow or waited at a given time | `diagnostics/query-store/longest-queries-in-a-period.sql`, `longest-waits-in-a-period.sql` |
| Queries that timed out or failed | `diagnostics/query-store/aborted-queries.sql`, `extended-events/on-prem/timeouts-create.sql` then `timeouts-read.sql` |
| Query Store state and why it is read-only | `diagnostics/query-store/query-store-state.sql` |
| Find a query by text or by id | `diagnostics/query-store/find-query-by-text.sql`, `find-query-by-query_id.sql` |
| Plans that compile slowly | `diagnostics/query-store/compile-time.sql` |

### Indexes and statistics

| Need | Script |
|---|---|
| Missing indexes | `index-management/missing-indexes.sql` (plan cache DMVs), `diagnostics/query-store/missing-indexes.sql` (Query Store plans) |
| Unused indexes | `index-management/unused-indexes.sql` |
| Index usage (seeks, scans, updates) | `index-management/index-usage.sql`, `index-on-table.sql` for one table |
| Fragmentation | `index-management/index-physical-stats-limited.sql` (cheap), `index-physical-stats-detailed.sql` (page density, reads every page) |
| Which queries use an index | `index-management/index-used-by-queries.sql`, `index-used-by-queries-query-store.sql` |
| Heaps with forwarded records | `database-information/tables-information/forwarded-records.sql`, `database-information/heaps-fragmentation.sql` |
| Clustered index on a GUID | `index-management/clustered-index-on-uniqueidentifier.sql` |
| Duplicate or stale statistics | `database-information/statistics/` |

### Database content, size and storage

| Need | Script |
|---|---|
| Size of each database, data and log | `database-information/size-and-allocation/database-sizes.sql` |
| Biggest tables | `database-information/size-and-allocation/table-sizes.sql` |
| Files and free space | `database-information/size-and-allocation/database-files.sql`, `server-information/free-disk-space.sql` |
| Which tables are compressed, and how | `database-information/compression/compressed-objects.sql` |
| What compression would save | `database-information/compression/estimate-compression-benefits-on-a-table.sql`, `-on-all-tables.sql`, `-on-a-database.sql` |
| Why a transaction log is not reused | `database-information/transaction-log/transaction-logs.sql`, `active-portion.sql` |
| Partitioning layout | `database-information/size-and-allocation/partition-information.sql` |
| Database options and risky settings | `database-information/database-options.sql`, `bad-databases.sql`, `databases-compatibility-level.sql` |
| Search a string in procedures and views | `database-information/code-modules/search-in-modules.sql` |
| Columnstore, In-Memory OLTP, ledger | `database-information/columnstore/`, `database-information/in-memory/`, `database-information/ledger/` |

### Instance, security and high availability

| Need | Script |
|---|---|
| First look at an unknown server | `server-information/quick-audit.sql`, `sql-version.sql`, `server-uptime.sql` |
| CPU, NUMA and memory | `server-information/cores-and-numa.sql`, `server-information/memory/sqlserver-memory.sql` |
| Who is sysadmin, who has which permission | `security/sysadmin-logins.sql`, `permissions-audit.sql` |
| Orphaned users after a restore | `security/orphaned-users.sql` |
| Backups taken | `database-administration/maintenance/get-backups.sql`, `stored-procedures/sp_CheckBackups.sql` |
| Failed or slow Agent jobs | `database-administration/sqlagent/jobs-history.sql`, `job-steps-perf-analysis.sql` |
| Ola Hallengren maintenance errors | `database-administration/dba-database/030.ola-check-log-for-errors.sql` |
| Availability group health and lag | `hadr/database-replica-states.sql`, `secondary-synchronization-lag.sql`, `availability-replicas-states.sql` |
| Failover history | `hadr/failover-times.sql` |
| Automatic seeding progress | `hadr/automatic-seeding/` |
| Azure SQL Database resource use | `cloud/azure/azure-sql-database/dm_db_resource_stats.sql`, `service-level-info.sql` |

## Known traps

- Scripts are written for SSMS, which sets `QUOTED_IDENTIFIER ON`. `sqlcmd` leaves it OFF: run them with `sqlcmd -I`, or every script that uses XML methods (`.value()`, `.nodes()`, `.exist()`) fails with Msg 1934.
- `object_name` in `sys.dm_os_performance_counters` is a blank-padded `nchar`, and its prefix is `SQLServer:` on a default instance but `MSSQL$<instance>:` on a named one. Filter with `RTRIM(object_name) LIKE N'%:Databases'`: an equality on `SQLServer:` misses named instances, and a `LIKE` without `RTRIM` or a trailing `%` matches no row at all.
- Query Store and Extended Events store UTC times: compare them with `SYSDATETIMEOFFSET()` or `GETUTCDATE()`, never with `GETDATE()` or `CURRENT_TIMESTAMP`.
- Extended Events readers must read every rollover file (`<session>*.xel`), not only the current one.
- `stored-procedures/sp_databases.sql` installs `master.dbo.sp_databases`, which can never be called: `EXEC sp_databases`, even fully qualified, runs the system procedure `sys.sp_databases`.

## Keeping this file true

A new script gets an entry in its folder README. If it changes something on the server, generates commands or installs an object, it also goes in the matching list above; if it answers a common need, add it to the tables.
