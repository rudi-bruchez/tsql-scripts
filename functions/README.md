# Functions

Reusable T-SQL functions for SQL Server administration.

## 📝 [fn_isJobRunning](./fn_isJobRunning.sql)

Returns 1 if a SQL Agent job is currently running, 0 otherwise. Useful for checking job status before starting dependent operations or preventing concurrent executions.

## 📝 [fn_maintenanceOperation](./fn_maintenanceOperation.sql)

Returns the start time of the oldest maintenance operation (UPDATE STATISTICS, DBCC) currently in progress on a database. Useful to determine if maintenance is running and to avoid conflicts with schema stability locks held by maintenance operations.

## 📝 [fn_tableSize](./fn_tableSize.sql)

Inline table-valued function meant to return the row count of a table from partition metadata, without scanning the table. As written, it ignores its `@tableName` parameter and always reads `dbo.GatewayOrdersSlim`: edit the code before use.
