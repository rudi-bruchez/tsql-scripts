# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

A collection of T-SQL scripts and PowerShell utilities for SQL Server administration and diagnostics. Targets SQL Server 2014+, Azure SQL Database, and Azure SQL Managed Instance.

**Author**: Rudi Bruchez (rudi@babaluga.com)
**License**: MIT ("go ahead license")

## Project Structure

Each directory has a README.md with links and descriptions of all scripts.

### Core Directories
- **diagnostics/** - Execution stats, IO, locking, memory, query-store, sessions, tempdb, wait-statistics
- **database-administration/** - Maintenance, DDL generation, SQL Agent, alerts, dba-database setup
- **database-information/** - Size, allocation, compression, statistics, indexes, in-memory, ledger
- **index-management/** - Missing indexes, usage stats, fragmentation analysis
- **stored-procedures/** - Reusable procedures (sp_activeTransactions, sp_databases, sp_logspace, etc.)
- **functions/** - Reusable T-SQL functions (fn_isJobRunning, fn_tableSize, fn_maintenanceOperation)

### Platform-Specific
- **cloud/azure/** - Azure SQL Database and Managed Instance queries
- **cloud/aws/rds/** - AWS RDS SQL Server scripts
- **extended-events/** - XEvent sessions for on-prem (`on-prem/`) and Azure SQL DB (`azure-sql-database/`)

### High Availability
- **hadr/** - AlwaysOn Availability Groups, WSFC, log shipping, automatic seeding

### Automation & Utilities
- **powershell/** - Automation scripts using SqlServer module and dbatools
- **monitoring/** - Backup, shrink, and DBCC operation monitoring
- **security/** - Logins, permissions, role audits
- **server-information/** - Version, CPU, memory, connections, schedulers
- **service-broker/** - Queue management and cleanup
- **replication/** - Transactional replication management

## Code Standards

### SQL File Header Template
```sql
-----------------------------------------------------------------
-- [Description]
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
```

### DMV Query Conventions
- Use `SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;` for diagnostics
- End DMV queries with `OPTION (RECOMPILE, MAXDOP 1);`

### Naming Conventions
- Stored procedures: `sp_[FunctionName]`
- Functions: `fn_[FunctionName]`
- Extended Events: `*-create.sql` to create session, `*-read.sql` to read results
- DBA database scripts: numbered prefixes for execution order (000., 010., 015., etc.)

### README.md Format
Each directory README uses:
- `## 📝 [filename](./filename.sql)` for script entries with description
- `### 📁 [dirname](./dirname/)` for subdirectory links

## Development Environment

- **IDE**: VS Code with SQL Server extensions, or SSMS/Azure Data Studio
- **No build system**: Scripts run directly
- **No testing framework**: Manual execution and validation
- **PowerShell modules**: SqlServer, dbatools

## Git Conventions

- Commit messages: lowercase, brief descriptions (e.g., "add README files", "Query Store")
- Branch: main
