# ☯ tsql-scripts

[![SQL Server](https://img.shields.io/badge/SQL%20Server-2014%2B-0078D4.svg)](https://learn.microsoft.com/en-us/sql/sql-server)
[![Azure SQL DB](https://img.shields.io/badge/Azure%20SQL-Database-0078D4.svg)](https://learn.microsoft.com/en-us/azure/azure-sql/database/sql-database-paas-overview)
[![Azure SQL MI](https://img.shields.io/badge/Azure%20SQL-Managed%20Instance-0078D4.svg)](https://learn.microsoft.com/en-us/azure/azure-sql/managed-instance/sql-managed-instance-paas-overview)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

Transact-SQL scripts and gists for administration and [diagnostics](./diagnostics/).

You'll also find some [management stored procedures](./stored-procedures/)

Feel free to use them and copy them. If you have significant improvements to propose, please fork the repo and propose a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests).

## Folders

You'll find here the following folders :

- [cloud](./cloud/): queries for [Azure SQL Database](./cloud/azure/azure-sql-database/), Azure SQL Managed Instance and [AWS RDS](./cloud/aws/rds/). Those queries use platform-specific views and metadata. Some Extended events for Azure SQL Database can also be found in [extended-events/azure-sql-database](./extended-events/azure-sql-database/).
- [database-administration](./database-administration/): queries for [database maintenance](./database-administration/maintenance/), [DDL generation](./database-administration/ddl-generation/), [SQL Server Agent](./database-administration/sqlagent/), [alerts](./database-administration/alerts/) and code to [create the `_dba` database](./database-administration/dba-database/) I use for some customers.
- [database-information](./database-information/): metadata about databases : [size](./database-information/size-and-allocation/), [compression](./database-information/compression/), [transaction log](./database-information/transaction-log/), etc.
- [diagnostics](./diagnostics/): diagnostics queries.
  - [execution](./diagnostics/execution/): diagnostics queries to inspect running queries, procedures and active transactions.
  - [execution-stats](./diagnostics/execution-stats/): statistics about query performances.
  - [IO](./diagnostics/IO/): information about physical IO.
  - [locking](./diagnostics/locking/): locking and blocking.
  - [memory](./diagnostics/Memory/): memory usage : buffer pool and plan cache.
  - [query-store](./diagnostics/query-store/): Query Store management.
  - [sessions](./diagnostics/sessions/): opened sessions.
  - [tempdb](./diagnostics/tempdb/): tempdb diagnostics queries, including version store.
  - [wait_statistics](./diagnostics/wait-statistics/): Wait statistics.
- [extended-events](./extended-events/): code to create extended events [on-prem](extended-events/on-prem/) and on [Azure SQL Database](extended-events/azure-sql-database/). You'll also find queries to read the content of the targets.
- [functions](./functions/): reusable T-SQL functions, like checking whether a SQL Agent job or a maintenance operation is running.
- [hadr](./hadr/): queries for AlwaysOn Failover Clustering and AlwaysOn Availability Groups.
- [howto](./howto/): T-SQL tips, like formatting numbers.
- [index-management](./index-management/): missing indexes, index usage, fragmentation analysis, etc.
- [math](./math/): statistical functions in T-SQL (error function, gamma, cumulative and inverse cumulative normal distribution).
- [monitoring](./monitoring/): queries to monitor current operations, like backups, shrink or DBCC execution.
- [powershell](./powershell/): Powershell scripts for administration.
- [replication](./replication/): Replication related queries.
- [security](./security/): logins, users, roles and permissions audits, orphaned users.
- [server-information](./server-information/): queries to get server / instance information.
- [service-broker](./service-broker/): Service Broker related queries
- [stored-procedures](./stored-procedures/): Stored procedure for quick info in your database, like getting active transactions, database information, memory status or [sp_logspace](./stored-procedures/sp_logspace.sql), a replacement for `DBCC SQLPERF (LOGSPACE)`. Also maintenance procedures, like [RebuildHeaps](./stored-procedures/RebuildHeaps.sql) for heaps with forwarded records.
