# Management Stored Procedures

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

## 📝 [sp_databases](./sp_databases.sql)

Returns databases with size information.

## 📝 [sp_indexes_analysis](./sp_indexes_analysis.sql)

Analyzes missing and existing indexes for all tables or a specific table in the current database.

## 📝 [sp_logspace](./sp_logspace.sql)

Replaces DBCC SQLPERF (LOGSPACE) with more information.

## 📝 [sp_memorystatus](./sp_memorystatus.sql)

Returns detailed information about SQL Server memory usage, from performance counters and memory clerks.

## 📝 [sp_monitor_maintenance](./sp_monitor_maintenance.sql)

Monitor running maintenance operations.

## 📝 [sp_sessions](./sp_sessions.sql)

Lists opened user sessions.
