# Management Stored Procedures

## 📝 [ConvertLobToMax](./ConvertLobToMax.sql)

Converts the deprecated `text`, `ntext` and `image` columns of a table to `varchar(max)`, `nvarchar(max)` and `varbinary(max)`, keeping NULL / NOT NULL. Created as `dbo.ConvertLobToMax` in the current database (not master), it works on tables of the database it lives in. Prints the `ALTER TABLE ... ALTER COLUMN` statements by default.

```sql
EXEC dbo.ConvertLobToMax @schema_name = N'dbo', @table_name = N'Orders', @Execute = 1;
```

| Parameter | Default | |
|---|---|---|
| `@schema_name` | | schema of the table |
| `@table_name` | | table to convert |
| `@Execute` | 0 | 0 = print the statements, 1 = run them |
| `@MoveInRow` | 0 | 1 = add `UPDATE t SET c = c` to bring values under 8000 bytes back in row |

The `ALTER` only changes metadata. The `@MoveInRow` update rewrites every row and is fully logged: run it in a maintenance window.

## 📝 [RebuildHeaps](./RebuildHeaps.sql)

Rebuilds heaps having more than a given number of forwarded records, in a list of databases or all user databases, worst first. Meant to be created in master or a DBA database and called from a SQL Agent job, like Ola Hallengren's maintenance solution. List-only mode by default, time limit, lock timeout per table, and a final error if anything failed so the job reports it. Procedure version of [rebuild-heaps-forwarded-records](../database-administration/maintenance/rebuild-heaps-forwarded-records.sql).

```sql
EXEC dbo.RebuildHeaps @Databases = N'Sales, Stock', @Execute = 1;
```

| Parameter | Default | |
|---|---|---|
| `@Databases` | NULL | comma separated list of databases, NULL = all user databases |
| `@MinForwarded` | 10 | rebuild heaps with more forwarded records than this |
| `@TimeLimitMinutes` | 240 | start no new rebuild after this, NULL = no limit |
| `@LockTimeoutMs` | 60000 | skip a table that can't be locked within this delay |
| `@Execute` | 0 | 0 = list only, 1 = rebuild |

On Standard Edition the rebuild is offline: the table is locked, reads included, and its nonclustered indexes are rebuilt too. Requires SQL Server 2017+.

## 📝 [sp_activeTransactions](./sp_activeTransactions.sql)

Lists active running transactions.

## 📝 [sp_CheckBackups](./sp_CheckBackups.sql)

Lists the backups taken in the last week from the msdb history, with type, duration, size, compressed size, backup file and recovery model, and whether this replica is the preferred backup replica of an availability group. Created in master. Databases with no backup in the last week do not appear.

## 📝 [sp_databaseSizes](./sp_databaseSizes.sql)

Data size, log size, log used and percentage, recovery model and log reuse wait of each user database whose name contains `@namePattern`, from the performance counters. Created in master. Example: `EXEC sp_databaseSizes @namePattern = N'sales';`. It was called `sp_databases`, a name the system procedure `sys.sp_databases` always takes over: if an older version is installed, drop `master.dbo.sp_databases`.

## 📝 [sp_df](./sp_df.sql)

Disk usage and free space of every volume holding a database file (size, free MB, free percentage), from `sys.dm_os_volume_stats`. Named after the Unix `df` command. Created in master.

## 📝 [sp_HadrState](./sp_HadrState.sql)

Availability group synchronization state: for each database, one row per secondary replica with health, commit lag in seconds, redo queue, redo rate, estimated minutes to catch up and `secondary_lag_seconds`. Run it on the primary replica. Created in master.

## 📝 [sp_indexes_analysis](./sp_indexes_analysis.sql)

Analyzes missing and existing indexes for all tables or a specific table in the current database.

## 📝 [sp_indexFragmentation](./sp_indexFragmentation.sql)

Fragmentation of the indexes and heaps of a table or of all tables in the current database, from `sys.dm_db_index_physical_stats` in `SAMPLED` mode: page count, page density, fragmentation percentage, fragments, depth, record count, forwarded and ghost records. On more than 10,000 pages `SAMPLED` reads 1% of the leaf pages, so the figures are estimates; below that it reads every page. Created in master and marked as a system object, so it runs in the context of the database it is called from. `@schema_name` is an exact schema name (default `dbo`); `@table_name` and `@index_name` are `LIKE` patterns (default `%`). Heaps have no index name: they are listed only when `@index_name` matches an empty string, as `%` does.

```sql
EXEC sp_indexFragmentation @table_name = N'Orders';
```

## 📝 [sp_lock2](./sp_lock2.sql)

Replacement for `sp_lock`: lists the locks held or requested, with the object name, lock mode, request status and the blocking session when the request waits. `@session_id` limits the output to one session, NULL (default) lists all sessions. Created in master.

```sql
EXEC sp_lock2 @session_id = 53;
```

## 📝 [sp_logspace](./sp_logspace.sql)

Replaces DBCC SQLPERF (LOGSPACE) with more information.

## 📝 [sp_memorystatus](./sp_memorystatus.sql)

Returns detailed information about SQL Server memory usage, from performance counters and memory clerks.

## 📝 [sp_MonitorMaintenance](./sp_MonitorMaintenance.sql)

Monitor running maintenance operations.

## 📝 [sp_sessions](./sp_sessions.sql)

Lists opened user sessions.

## 📝 [sp_WhoIsBlocking](./sp_WhoIsBlocking.sql)

Wrapper around Adam Machanic's [sp_WhoIsActive](http://whoisactive.com/), which must be installed, to investigate blocking: finds the block leaders, sorts by number of blocked sessions and adds task, transaction and additional information. Created in master.

## 📝 [sp_WhoIsRunning](./sp_WhoIsRunning.sql)

Wrapper around [sp_WhoIsActive](http://whoisactive.com/), which must be installed, that shows the running sessions (sleeping ones excluded) with a reduced column list, the query plan and the locks held. Created in master.

## 📝 [sp_WhoIsWho](./sp_WhoIsWho.sql)

Everything about one session as a single JSON document: session and connection details, current request, wait, query text and the in-flight execution plan from `sys.dm_exec_query_statistics_xml`. `@session_id` is mandatory. Created in master, requires SQL Server 2016 SP1+.

```sql
EXEC sp_WhoIsWho @session_id = 53;
```
