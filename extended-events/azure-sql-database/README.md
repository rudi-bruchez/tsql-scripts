# Extended Events for Azure SQL Database

Extended Events session scripts specifically for Azure SQL Database.

## 📝 [blocked-processes-create](./blocked-processes-create.sql)

Creates and starts an extended event session to capture blocked process reports on Azure SQL Database (with fixed 20-second block threshold). The stop statement is commented out: run it once the ring buffer is read.

## 📝 [blocked-processes-read](./blocked-processes-read.sql)

Reads and parses blocked process report events from Azure SQL Database, extracting details about blocking and blocked processes, wait times, and affected database objects.

## 📝 [long-queries-create](./long-queries-create.sql)

Creates and starts an extended event session to capture long-running queries (exceeding 5 seconds) with lightweight profiling and post-execution plans on Azure SQL Database. The stop statement is commented out: run it once the ring buffer is read.

## 📝 [read-exended-event](./read-exended-event.sql)

Reads the ring buffer of the `long_queries` session created by [long-queries-create](./long-queries-create.sql), extracting performance metrics like duration, CPU time, logical reads, and row counts. Change `@ExtendedEventsSessionName` to read another ring buffer session.

## 📝 [trace-procedure-create](./trace-procedure-create.sql)

Creates an extended event session to trace a specific stored procedure, capturing query post-execution plans and statement completion events for performance profiling.

## 📝 [trace-procedure-read](./trace-procedure-read.sql)

Queries the ring buffer of the `trace-procedure` session created by [trace-procedure-create](./trace-procedure-create.sql), extracting procedure execution metrics including duration, CPU, logical reads, and query execution plans.
