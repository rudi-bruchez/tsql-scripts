# Database Information

Scripts for querying database metadata, configuration, and object information.

## 📝 [bad-databases](./bad-databases.sql)

Identifies databases with non-standard settings (auto_close on, auto_shrink on, or auto_update_stats off) that may indicate configuration issues.

## 📝 [database-collations](./database-collations.sql)

Lists the server default collation and all database collations to identify databases with non-standard collation settings.

## 📝 [database-options](./database-options.sql)

Shows common database configuration settings like recovery model, containment, compatibility level, page verification, auto statistics, parameterization, isolation levels, and delayed durability.

## 📝 [databases-compatibility-level](./databases-compatibility-level.sql)

Reports compatibility level for each database and the server version to help identify version mismatches and upgrade readiness.

## 📝 [heaps-fragmentation](./heaps-fragmentation.sql)

Analyzes heap table fragmentation including ghost records, forwarded records, and fragmentation percentage to identify maintenance needs.

## 📝 [last-modified-objects](./last-modified-objects.sql)

Shows objects modified in the last week to track recent schema changes and code deployments.

## 📝 [last-modified-procedures](./last-modified-procedures.sql)

Lists stored procedures sorted by modification date to identify recently updated or deployed stored procedures.

## 📝 [list-databases](./list-databases.sql)

Displays all user databases with detailed status information including owner, compatibility level, recovery model, replication settings, and various database options.

## 📝 [objects-in-database](./objects-in-database.sql)

Counts objects by type in the current database to provide an overview of database structure and object inventory.

## 📝 [schema-owners](./schema-owners.sql)

Lists all schemas and their owners, useful for identifying schemas owned by non-dbo users which may indicate security or maintenance issues.

## 📝 [synonyms](./synonyms.sql)

Lists all synonyms in the current database with their base object names for understanding synonym usage and dependencies.

## Subdirectories

### 📁 [code-modules](./code-modules/)

Scripts for analyzing stored procedures, functions, and triggers.

### 📁 [columnstore](./columnstore/)

Columnstore index diagnostics.

### 📁 [compression](./compression/)

Data compression analysis and estimation.

### 📁 [indexes](./indexes/)

Index metadata and analysis.

### 📁 [in-memory](./in-memory/)

In-Memory OLTP diagnostics.

### 📁 [ledger](./ledger/)

SQL Server 2022 Ledger table metadata.

### 📁 [size-and-allocation](./size-and-allocation/)

Database size, file, and allocation analysis.

### 📁 [statistics](./statistics/)

Column and index statistics analysis.

### 📁 [tables-information](./tables-information/)

Table metadata and structure analysis.

### 📁 [transaction-log](./transaction-log/)

Transaction log analysis.
