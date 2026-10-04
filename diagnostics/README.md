# Diagnostics queries

## 📝 [Permissions for diagnostics](./permissions-for-diagnostics.sql)

Creates an `audit` server role with the permissions needed to run diagnostics without being sysadmin (`VIEW SERVER STATE`, `VIEW ANY DEFINITION`, `ALTER TRACE`, `ALTER ANY EVENT SESSION`) and adds a login to it. Replace `<login>` before running.

## 📝 [Execution](./execution/)

Running and active queries, also currently waiting queries.

## 📝 [Execution stats](./execution-stats/)

Using DMV like `sys.dm_exec_query_stats` to analyze queries.

## 📝 [IO](./IO/)

IO related diagnostic queries.

## 📝 [Locking](./locking/)

Locking and blocking related diagnostic queries.

## 📝 [Memory](./Memory/)

Memory related diagnostic queries: buffer, plan cache, query memory.

## 📝 [Query Store](./query-store/)

Query Store Management and information.

## 📝 [Sessions](./sessions/)

Lists and finds sessions: by host, in a specific database...

## 📝 [tempdb](./tempdb/)

Tempdb related diagnostics queries.

## 📝 [Wait statistics](./wait-statistics/)

Wait stats related queries.
