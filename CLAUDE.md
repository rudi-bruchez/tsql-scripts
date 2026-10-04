# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

A collection of T-SQL scripts and PowerShell utilities for SQL Server administration and diagnostics. Targets SQL Server 2014+, Azure SQL Database, and Azure SQL Managed Instance.

**Author**: Rudi Bruchez (rudi@babaluga.com)
**License**: MIT ("go ahead license")

Which script answers which need, and which scripts change the server: see @AGENTS.md.

## Project Structure

Each script directory has a README.md with links and descriptions of all scripts (a folder holding only a config example is documented by its parent README).

### Core Directories
- **diagnostics/** - Execution stats, IO, locking, memory, query-store, sessions, tempdb, wait-statistics
- **database-administration/** - Maintenance, DDL generation, SQL Agent, alerts, dba-database setup
- **database-information/** - Size, allocation, compression, statistics, indexes, in-memory, ledger
- **index-management/** - Missing indexes, usage stats, fragmentation analysis
- **stored-procedures/** - Reusable procedures (sp_activeTransactions, sp_databaseSizes, sp_logspace, etc.)
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

### Catalogue marker for sqlq

`sqlq`, the query runner of db-ai-toolkit, can call a script of this repository by name when the script carries one marker line in its header. The marker is a comment: SSMS and `sqlcmd` run the file exactly as before. A script without a marker is ignored by `sqlq`.

```sql
-----------------------------------------------------------------
-- Get sessions from a specific host
-- sqlq: name=sessions-by-host params=hostname
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
```

- Form: `-- sqlq: name=<name> [params=a,b] [heavy]`, keys separated by spaces. `name=` is required; `params=` lists, separated by commas, the variables a caller may override (ASCII letters, digits and `_`, no duplicate); `heavy`, without a value, flags a script that is expensive to run. Any other key rejects the script, so a typo in `heavy` does not pass for its absence.
- Placement: in the header (the run of lines at the top of the file that are empty or start with `--`), directly under the description line. The summary `sqlq` publishes is the nearest comment line above the marker that is not empty, not only dashes, and not a URL: a marker placed under the licence line would publish the licence. One marker per file. Any line that starts with `--` then the word `sqlq` counts as a marker attempt, colon or not; an attempt without the colon, a second marker, or a marker below the header makes the script rejected rather than invisible.
- Name: `^[a-z][a-z0-9-]{1,48}$`, after the need rather than after the file (`cpu-numa-layout` for `cores-and-numa.sql`). It must be unique in this repository and must not be the name of a query bundled with db-ai-toolkit (`missing-indexes`, `tables-largest`, ...): the bundled query keeps its name and the script is rejected.
- Publication: the name and the summary are sent to the model provider on every session. Never put a client, host or database name in them, nor in the file name.
- What the guard refuses: a script containing `GO`, `USE`, `EXEC` or `EXECUTE`, `INTO` (so no `SELECT ... INTO #t` and no `FETCH ... INTO`), or any write keyword (`INSERT`, `UPDATE`, `DELETE`, `MERGE`, `CREATE`, so no temporary table, `ALTER`, `DROP`, `DBCC`, ...) is rejected, even where the statement would only read. Comments and string literals are not inspected. The file must be UTF-8 (SSMS can save UTF-16: re-save it), with LF or CRLF line endings, under 1 MiB, and not a symbolic link.
- Overridden variables: each name in `params=` needs exactly one declaration, alone on its line, of the form `DECLARE @p <type> = <expression>;` or `DECLARE @p AS <type> = <expression>;`. The final `;` is on the same line; a trailing `--` comment is allowed. One variable per `DECLARE`. The type is written bare (not `[int]`). The initializer is one expression (literal, variable, function call, operators and parentheses; no `CASE`, no `COLLATE`). No `IF`, `ELSE`, `WHILE`, `BEGIN`, `GOTO` or label may appear anywhere before the declaration, since the line might then not run. The variable is never assigned after its declaration (`SET @p =`, `SELECT @p =`, `+=`, `OUTPUT`); `WHERE @p = 1` or `IIF(@p = 1, ...)` compare and are fine. In any marked script, whether or not it lists `params=`, no identifier may start with `@sqlq_` and every variable name must be ASCII.
- Accepted types and values: `nvarchar(n)`, `nchar(n)`, `sysname` (at most n UTF-16 units), `nvarchar(max)`; `varchar(n)`, `char(n)`, `varchar(max)` (ASCII values only); `tinyint`, `smallint`, `int`, `bigint` (decimal integer in range); `bit` (`0`, `1`, `true`, `false`); `date` (`YYYY-MM-DD`); `datetime`, `datetime2(n)` (`YYYY-MM-DD` or `YYYY-MM-DDTHH:MM[:SS]`); `smalldatetime` (`YYYY-MM-DD` or `YYYY-MM-DDTHH:MM`). Never fractional seconds. Any other type (`decimal`, `float`, `uniqueidentifier`, ...) rejects the script. A variable the caller does not pass keeps the default written in the file.
- Editing the marker line (renaming, adding `heavy`, changing `params=`) keeps the verification `sqlq` records for the SQL below it; changing any other line resets it.
- Check after adding or changing markers, from `db-ai-toolkit/tools`: `DB_AI_TOOLKIT_TSQL_SCRIPTS=<clone> go test ./internal/sqlq -run '^TestRealCloneHasNoRejectedEntry$' -count=1 -v`. Every marked script must pass; a rejected one prints its reason. Never change the SQL of a script to make it fit: leave it without a marker.

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
