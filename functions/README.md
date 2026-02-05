# Functions

Reusable T-SQL functions for SQL Server administration.

## 📝 [fn_isJobRunning](./fn_isJobRunning.sql)

Returns 1 if a SQL Agent job is currently running, 0 otherwise. Useful for checking job status before starting dependent operations or preventing concurrent executions.

## 📝 [fn_maintenanceOperation](./fn_maintenanceOperation.sql)

Returns the start time of the oldest maintenance operation (UPDATE STATISTICS, DBCC) currently in progress on a database. Useful to determine if maintenance is running and to avoid conflicts with schema stability locks held by maintenance operations.

## 📝 [fn_tableSize](./fn_tableSize.sql)

Returns the row count for a specified table using partition metadata. Provides a fast way to get table size without scanning the actual table.
