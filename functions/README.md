# Functions

Reusable T-SQL functions for SQL Server administration.

## 📝 [fn_isJobRunning](./fn_isJobRunning.sql)

Returns 1 if a SQL Agent job is currently running, 0 otherwise. Useful for checking job status before starting dependent operations or preventing concurrent executions.

## 📝 [fn_maintenanceOperation](./fn_maintenanceOperation.sql)

Returns the start time of the oldest maintenance operation (UPDATE STATISTICS, or any DBCC command such as the `DBCC TABLE CHECK` phases of a `DBCC CHECKDB`) currently in progress on a database, NULL if there is none. Useful to determine if maintenance is running and to avoid conflicts with schema stability locks held by maintenance operations.

## 📝 [fn_tableSize](./fn_tableSize.sql)

Inline table-valued function returning the row count of a table from partition metadata, without scanning the table: one row with the table name, the row count summed over all partitions, and the count formatted with thousands separators. `@tableName` is resolved by `OBJECT_ID` in the database where the function is created, so pass a schema-qualified name (`N'Sales.Orders'`, or `N'[my schema].[my table]'`). The count comes from `sys.partitions`, which Microsoft documents as approximate.

```sql
SELECT * FROM dbo.fn_tableSize(N'dbo.Orders');
```
