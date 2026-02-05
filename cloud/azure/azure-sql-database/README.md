# Azure SQL Database Queries

Diagnostic and monitoring queries specific to Azure SQL Database.

## 📝 [db-wait-stats](./db-wait-stats.sql)

Wait statistics for Azure SQL Database using the dedicated `sys.dm_db_wait_stats` view. Filters out benign waits and calculates average signal wait time.

## 📝 [disk-usage-by-top-tables](./disk-usage-by-top-tables.sql)

Shows disk usage by table including row counts, compression type, allocation type, data pages, and size in MB. Ordered by row count descending.

## 📝 [dm_db_resource_stats](./dm_db_resource_stats.sql)

Returns Azure SQL Database resource statistics including DTU/CPU limits, CPU percentage, memory usage, data IO, log write percentage, worker utilization, and session counts. Data from the last hour at 15-second intervals.

## 📝 [io-file-stats](./io-file-stats.sql)

IO statistics per database file using `sys.dm_io_virtual_file_stats`. Shows read/write latency, average bytes per operation, and file sizes. Useful for identifying IO bottlenecks.

## 📝 [service-level-info](./service-level-info.sql)

Shows Azure SQL Database service tier information including visible schedulers (vCores) and memory manager performance counters (database cache, target memory, total memory).
