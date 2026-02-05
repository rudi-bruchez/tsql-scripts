# Database Administration

Scripts for database administration tasks.

## 📝 [clear-proc-in-cache](./clear-proc-in-cache.sql)

Demonstrates how to find and clear specific stored procedure execution plans from SQL Server plan cache using either legacy DBCC FREEPROCCACHE or modern ALTER DATABASE SCOPED CONFIGURATION.

## 📝 [get-untrusted-constraints](./get-untrusted-constraints.sql)

Identifies untrusted CHECK constraints that were not validated after being created, which may impact query optimization.

## 📝 [remove-useless-schemas](./remove-useless-schemas.sql)

Drops default SQL Server database schemas (db_accessadmin, db_owner, etc.) that are created for historical compatibility but typically unused.

## Subdirectories

### 📁 [alerts](./alerts/)

Scripts to manage SQL Server alerts using T-SQL.

### 📁 [configuration](./configuration/)

Scripts to get and set database-level configuration options.

### 📁 [dba-database](./dba-database/)

Scripts to create the `_dba` maintenance database with Ola Hallengren's solution.

### 📁 [ddl-generation](./ddl-generation/)

Scripts to generate DDL for database objects.

### 📁 [maintenance](./maintenance/)

Scripts for checking database maintenance and backups.

### 📁 [sqlagent](./sqlagent/)

Scripts to manage SQL Server Agent.
