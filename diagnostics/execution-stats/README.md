# Execution Stats

Scripts using DMVs like `sys.dm_exec_query_stats` to analyze query performance.

## 📝 [function-stats](./function-stats.sql)

Displays execution statistics for scalar functions including caching time, execution count, and resource consumption.

## 📝 [parallelism_analysis](./parallelism_analysis.sql)

Analyzes performance of queries using parallelism, showing execution statistics and degree of parallelism metrics for cached query plans.

## 📝 [query_stats](./query_stats.sql)

Displays the heaviest queries in the plan cache with execution counts, logical reads, worker time, and execution timing metrics.

## 📝 [sheduler-monitor](./sheduler-monitor.sql)

Monitors scheduler activity from the last 256 minutes using the scheduler monitor ring buffer: SQL Server CPU, CPU used by other processes, kernel time share, page faults and working set delta.

## 📝 [trigger-stats](./trigger-stats.sql)

Shows trigger execution statistics with performance metrics and execution plans, for the current database by default or for all databases when `@ForCurrentDbOnly` is set to 0.

## 📝 [trigger-stats-detailed](./trigger-stats-detailed.sql)

Provides comprehensive execution statistics for database triggers including worker time, reads, writes, and execution plans.

## Subdirectories

### 📁 [stored-procedures](./stored-procedures/)

Stored procedure execution analysis scripts.
