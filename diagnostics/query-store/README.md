# Query Store management queries

## 📝 [Activate the Query Store](./activate-query-store.sql)

Enables the Query Store in read-write mode on a database, with recommended settings: 30 days retention, 2000 MB maximum size, 60 minutes statistics interval, size based cleanup and `AUTO` capture mode. Set the database name with the SSMS template parameter `<db_name>` (Ctrl+Shift+M), and adjust the settings if needed.

## 📝 [List enabled databases](./list-databases.sql)

Lists databases where the query store is enabled.

## 📝 [Query Store state](./query-store-state.sql)

Shows the Query Store desired and actual state, capture mode and storage size in the current database,
especially why the Query Store is read-only, if it is the case.

## 📝 [Find query by query_id](./find-query-by-query_id.sql)

Finds a query in the Query Store when you know the `query_id`.

## 📝 [Find query by text](./find-query-by-text.sql)

Finds queries in the Query Store that contain a specific string.

## 📝 [Global runtime stats](./global-runtime-stats.sql)

Totals per day, over everything the Query Store holds in the current database: executions, duration and CPU time (ms) and logical reads (KB). Same query as the SSMS Query Store report.

## 📝 [Global runtime stats in a period](./global-runtime-stats-in-period.sql)

Same daily totals as above, limited to a period. Set `@interval_start_time` and `@interval_end_time` (with their UTC offset) before running.

## 📝 [Top consuming queries](./top-consuming-queries.sql)

Lists the 50 queries with the highest average duration over the last day, with the calling object, the number of executions and the number of plans.

## 📝 [Longest queries in a period](./longest-queries-in-a-period.sql)

Lists the runtime statistics of the statistics interval containing `@when`, sorted by maximum duration. Only queries that belong to a module (procedure, function, trigger) are returned. Set `@when` before running, in the local time of the server. It is converted with the current UTC offset of the server, so a time on the other side of a daylight saving change is one hour off.

## 📝 [Longest waits in a period](./longest-waits-in-a-period.sql)

Lists the wait statistics (`sys.query_store_wait_stats`) of the statistics interval containing `@when`, per query plan and wait category, sorted by total wait time, with the calling module and the plan. Set `@when` before running, in the local time of the server. It is converted with the current UTC offset of the server, so a time on the other side of a daylight saving change is one hour off.

## 📝 [I/O wait stats](./wait-stats-io.sql)

Shows, per statistics interval, the average and maximum query wait times for data reads (`Buffer IO`) and transaction log writes (`Tran Log IO`), from the Query Store wait statistics, and the largest standard deviation of a single plan (the Query Store keeps no execution count with the wait statistics, so the deviations of several plans cannot be combined into one). Replace `<database>` in the `USE` statement before running.

## 📝 [Aborted queries](./aborted-queries.sql)

Lists queries whose executions were aborted (by the client, typically a timeout) or ended with an exception during the last two hours.

## 📝 [Stored procedure stats](./stored-procedure-stats.sql)

Shows everything the Query Store knows about the queries of one stored procedure: compilation, context settings, plans, and runtime statistics per interval, the most recent first. Set `@procedure_name` (schema and name) before running.

## 📝 [Compilation time per plan](./compile-time.sql)

Lists non trivial plans of user queries with their average and last compilation duration, last compilation time, plan size and total size of the plans in the Query Store.

## 📝 [Plans and compilation time per query hash](./plans-and-compilation-time.sql)

Lists the 100 query hashes whose last compilation took more than one second, with the number of queries and plans sharing that hash, the bind duration and the largest plan size. Useful to find queries that compile slowly or produce many plans.

## 📝 [Missing indexes](./missing-indexes.sql)

Extracts the missing index suggestions from the Query Store plans of the last week, one row per query, with the table, impact, equality, inequality and included columns, executions, average reads and CPU. Requires SQL Server 2017 or later (`STRING_AGG`).

## 📝 [List query hints](./query-hints-list.sql)

Lists the Query Store hints set in the current database (`sys.query_store_query_hints`) with the query text, source, failure count and reason, and generates the `sp_query_store_clear_hints` command to remove each one. SQL Server 2022 and later, Azure SQL.

## 📝 [Set query hints](./query-hints-set.sql)

Finds queries executed during the last week whose text contains `@sql_to_search` and that have no hint yet, and generates the `sp_query_store_set_hints` command to add `@hint_to_add`, with their execution statistics. The commands are not executed. Set both variables before running. SQL Server 2022 and later, Azure SQL.
