# ☯ tsql-scripts

Transact-SQL scripts and gists for administration and [diagnostics](./diagnostics/).

You'll also find some [management stored procedures](./stored-procedures/)

Feel free to use them and copy them. If you have significant improvements to propose, please fork the repo and propose a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests).

## Folders

You'll find here the following folders :

- [Azure](./azure/) &mdash; queries for [Azure SQL Database](./azure/azure-sql-database/) and Azure Managed Instances administration and diagnostics. Those queries use specific Azure views and metadata. Some Extended events for Azure SQL Database can also be found in [extended-events/azure-sql-database](./extended-events/azure-sql-database/).
- [database-administration](./database-administration/) &mdash; queries for [database maintenance](./database-administration/maintenance/), [DDL generation](./database-administration/ddl-generation/), informations about [security principals and privileges](./database-administration/security/), [SQL Server Agent](./database-administration/sqlagent/), [alerts](./database-administration/alerts/) and code to [create the `_dba` database](./database-administration/dba-database/) I use for some customers.
- [database-information](./database-information/) &mdash; metadata about databases : [size](./database-information/size-and-allocation/), [compression](./database-information/compression/), [transaction log](./database-information/transaction-log/), etc.
- [diagnostics](./diagnostics/) &mdash; diagnostics queries.
  - [execution](./diagnostics/execution/) &mdash; diagnostics queries to inspect running queries, procedures and active transactions.
  - [execution-stats](./diagnostics/execution-stats/) &mdash; statistics about query performances.
  - [IO](./diagnostics/IO/) &mdash; information about physical IO.
  - [locking](./diagnostics/locking/) &mdash; locking and blocking.
  - [memory](./diagnostics/Memory/) &mdash; memory usage : buffer pool and plan cache.
  - [query-store](./diagnostics/query-store/) &mdash; Query Store management.
  - [sessions](./diagnostics/sessions/) &mdash; opened sessions.
  - [tempdb](./diagnostics/tempdb/) &mdash; tempdb diagnostics queries, including version store.
  - [wait_statistics](./diagnostics/wait-statistics/) &mdash; Wait statistics.
- [extended-events](./extended-events/) &mdash; code to create extended events [on-prem](extended-events/on-prem/) and on [Azure SQL Database](extended-events/azure-sql-database/). You'll also find queries to read the content of the targets.
- [hadr](./hadr/) &mdash; queries for AlwaysOn Failover Clustering and AlwaysOn Availability Groups.
- [index-management](./index-management/) &mdash; missing indexes, index usage, fragmentation analysis, etc.
- [monitoring](./monitoring/) &mdash; queries to monitor current operations, like backups, shrink or DBCC execution.
- [powershell](./powershell/) &mdash; Powershell scripts for administration.
- [replication](./replication/) &mdash; Replication related queries.
- [server-information](./server-information/) &mdash; queries to get server / instance information.
- [service-broker](./service-broker/) &mdash; Service Broker related queries
- [stored-procedures](./stored-procedures/) &mdash; Stored procedure for quick info in your database, like getting active transactions, database information, memory status or [sp_logspace](./stored-procedures/sp_logspace.sql), a replacement for `DBCC SQLPERF (LOGSPACE)`.
