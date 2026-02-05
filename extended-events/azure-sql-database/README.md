# Extended Events for Azure SQL Database

Extended Events session scripts specifically for Azure SQL Database.

## 📝 [blocked-processes-create](./blocked-processes-create.sql)

Creates an extended event session to capture blocked process reports on Azure SQL Database (with fixed 20-second block threshold).

## 📝 [blocked-processes-read](./blocked-processes-read.sql)

Reads and parses blocked process report events from Azure SQL Database, extracting details about blocking and blocked processes, wait times, and affected database objects.

## 📝 [long-queries-create](./long-queries-create.sql)

Creates an extended event session to capture long-running queries (exceeding 5 seconds) with lightweight profiling and post-execution plans on Azure SQL Database.

## 📝 [read-exended-event](./read-exended-event.sql)

Reads extended event data from an Azure SQL Database ring buffer target, extracting performance metrics like duration, CPU time, logical reads, and row counts.

## 📝 [trace-procedure-create](./trace-procedure-create.sql)

Creates an extended event session to trace a specific stored procedure, capturing query post-execution plans and statement completion events for performance profiling.

## 📝 [trace-procedure-read](./trace-procedure-read.sql)

Queries the 'Perf2-procedure' extended event session data from ring buffer, extracting procedure execution metrics including duration, CPU, logical reads, and query execution plans.
