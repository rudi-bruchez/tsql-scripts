# Monitoring

Scripts for monitoring long-running SQL Server operations.

## 📝 [current-dbcc-operations](./current-dbcc-operations.sql)

Monitors running DBCC operations (SHRINK, CHECKDB, etc.) showing progress percentage, elapsed time, wait types, and parallelism information. Useful for tracking maintenance operations.

## 📝 [monitor-backup-operations](./monitor-backup-operations.sql)

Shows the progress percentage of currently running backup operations. Simple query to check backup completion status.

## 📝 [monitor-long-transactions](./monitor-long-transactions.sql)

Stored procedure that monitors for long-running transactions and sends email alerts with detailed HTML reports. Reports include transaction details, session info, log usage, and isolation levels. Configure with database mail profile and operator.

## 📝 [shrink-monitoring](./shrink-monitoring.sql)

Monitors running database shrink operations showing start time, status, wait types, percent complete, and estimated completion time.

## Subdirectories

### 📁 [queries-for-dashboards](./queries-for-dashboards/)

Queries designed for monitoring dashboards and visualization tools.
