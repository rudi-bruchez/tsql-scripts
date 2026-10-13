# IO

IO-related diagnostic queries for identifying bottlenecks and latency issues.

## 📝 [checkpoint-message-from-errorlog](./checkpoint-message-from-errorlog.sql)

Retrieves FlushCache checkpoint messages from SQL Server error log, indicating long checkpoint operations.

## 📝 [dm_io_virtual_file_stats](./dm_io_virtual_file_stats.sql)

Shows IO stall statistics per database and file with read/write latency and average bytes per operation.

## 📝 [dm_io_virtual_file_stats-delta](./dm_io_virtual_file_stats-delta.sql)

Measures IO latency, throughput and average IOs in flight per file and per drive over a sampling window (5 minutes by default), instead of the cumulative values since startup. Explains how to tell queueing from a slow device.

## 📝 [io-wait-statistics-for-monitoring](./io-wait-statistics-for-monitoring.sql)

Queries specific IO wait types (PAGEIOLATCH_SH, WRITELOG, PAGEIOLATCH_EX) for monitoring and Prometheus integration.

## 📝 [io-warning-from-errorlog](./io-warning-from-errorlog.sql)

Extracts IO warning messages from the error log showing files with IO delays exceeding 15 seconds.

## 📝 [pageiolatch-by-index](./pageiolatch-by-index.sql)

Reports page IO latch wait statistics per index, identifying indexes with IO contention.

## 📝 [pageiolatch-on-server](./pageiolatch-on-server.sql)

Shows server-wide page IO latch statistics across all databases grouped by index.

## 📝 [pageiolatch-stats](./pageiolatch-stats.sql)

Displays PAGEIOLATCH wait statistics with wait counts and average wait times from the global wait stats.
