# Execution Stats

Scripts using DMVs like `sys.dm_exec_query_stats` to analyze query performance.

## 📝 [function-stats](./function-stats.sql)

Displays execution statistics for scalar functions including caching time, execution count, and resource consumption.

## 📝 [parallelism_analysis](./parallelism_analysis.sql)

Analyzes performance of queries using parallelism, showing execution statistics and degree of parallelism metrics for cached query plans.

## 📝 [query_stats](./query_stats.sql)

Displays the heaviest queries in the plan cache with execution counts, logical reads, worker time, and execution timing metrics.

## 📝 [sheduler-monitor](./sheduler-monitor.sql)

Monitors scheduler activity from the last 256 minutes using ring buffers to track CPU usage, page faults, and memory utilization.

## 📝 [trigger-stats](./trigger-stats.sql)

Shows trigger execution statistics across databases with performance metrics and trigger type information.

## 📝 [trigger-stats-detailed](./trigger-stats-detailed.sql)

Provides comprehensive execution statistics for database triggers including worker time, reads, writes, and execution plans.

## Subdirectories

### 📁 [stored-procedures](./stored-procedures/)

Stored procedure execution analysis scripts.
