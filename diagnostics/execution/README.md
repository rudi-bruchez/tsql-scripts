# Execution related diagnostics queries

## 📝 [Running requests, short version](./running-requests-short.sql)

Lists the requests currently running on the instance (sessions above 50, excluding the current one) with their query text, database, elapsed time, current and last wait, open transaction count and cached query plan.

## 📝 [Running requests, detailed](./running-requests-detailed.sql)

Lists running user requests with login, host, waits, CPU, reads and writes, memory grant and blocking session. Background, sleeping and system tasks (AlwaysOn redo, Service Broker, `sp_server_diagnostics`...) are filtered out, and the statement plan text replaces the query text when the latter is not available.

## 📝 [Running requests, full details (SQL Server 2008)](./running-requests-detailed-sql2008.sql)

Lists running user requests with the full batch and the current statement text, calling procedure, waits, I/O, percent complete, the cached plan and the plan of the current statement, plus memory grant information from `sys.dm_exec_query_memory_grants`. Written to work on SQL Server 2008, sorted by elapsed time.

## 📝 [Running requests with their live plan](./running-plans-using-ligthweight-profile.sql)

Lists running user requests with their cached plan and their in-flight plan with live statistics, from `sys.dm_exec_query_statistics_xml`. It first enables trace flag 7412 globally (`DBCC TRACEON (7412, -1)`) to turn on lightweight profiling, which is only needed on SQL Server 2016 SP1 to 2017: remove that line on 2019 and later, where it is on by default.

## 📝 [sp_WhoIsActive examples](./sp_whoisactive.sql)

Two example calls of Adam Machanic's `sp_WhoIsActive`, which must be installed first: one with query plans, one with a reduced column list that excludes sleeping sessions and a given host. Replace `SERVERNAME` in `@not_filter` with the host name to exclude.

## 📝 [Long running queries](./long-running-queries.sql)

Lists user requests running for more than 30 seconds, with query text, waits, CPU, memory grant, degree of parallelism, host, program and login. Change the threshold (`30000` milliseconds) in the `WHERE` clause if needed.

## 📝 [Running procedures](./running-procedures.sql)

Lists the currently running requests with the database, the name of the calling module, the running time in seconds, the current statement and a ready to copy `KILL` command. Ad hoc requests are listed too, with an empty procedure name.

## 📝 [Waiting tasks](./waiting_tasks.sql)

Lists user sessions that currently have a task in `sys.dm_os_waiting_tasks`, with the wait type, wait duration, blocking session, command and query text. Benign background waits (Service Broker, Extended Events, `WAITFOR`, `SLEEP_TASK`...) are filtered out.

## 📝 [Active transactions](./active-transactions.sql)

Lists all open transactions with their type, state, start time and duration, database, log reuse wait, log bytes reserved and used, log size and % used, and the owning session (login, host, program, isolation level, last query text). Sorted by start time, the oldest transaction first.

## 📝 [Running maintenance operations](./running-admin-operations.sql)

Follows running administrative / maintenance requests (`DBCC`, `BACKUP`, `RESTORE`), along with percent complete, transaction log size and % usage.

## 📝 [Running BULK INSERT operations](./running-bulk-inserts.sql)

Follows running requests having the `BULK INSERT` command type. So `BULK INSERT` and `bcp` operations, along with transaction log size and % usage.

## 📝 [Batch requests per second](./batch-requests-for-last-10secs.sql)

Reads the `Batch Requests/sec` performance counter twice, 10 seconds apart, and returns the average number of batch requests per second over that period. The script waits 10 seconds before returning.

## 📝 [Execution activity per database](./execution-activity-per-database.sql)

Aggregates the plan cache statistics (`sys.dm_exec_query_stats`) per database: executions, logical and physical reads, CPU and elapsed time (also divided by the number of CPUs), rows, along with the collation, auto close, auto shrink and RCSI settings. Each query's figures are averaged per minute since its plan was cached, then summed, so the result is a rate rather than a total; `master` and `model` are excluded.
