# Wait Statistics

Wait statistics analysis queries.

## 📝 [reinitialize-stats](./reinitialize-stats.sql)

Clears wait statistics using DBCC SQLPERF to reset counters for fresh analysis.

## 📝 [session-wait-stats](./session-wait-stats.sql)

Displays wait statistics for the current session to analyze waits after executing a query or procedure.

## 📝 [waits-statistics](./waits-statistics.sql)

Shows cumulative server wait statistics filtered to exclude system waits, with percentage contribution and average wait times.

## 📝 [waits-stats-per-sessions](./waits-stats-per-sessions.sql)

Breaks down wait statistics by session including login name, database, and per-session wait type information.
