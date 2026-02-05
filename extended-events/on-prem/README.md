# Extended Event Sessions (On-Prem)

Extended event sessions to track events on on-prem SQL Server instances.

## How to get session events

If you are using the "event file" target, the session files will usually be in the `log` directory of SQL Server.

You can find this directory by using [this query](/server-information/get-sqlserver-log-directory.sql)

A more complete query to identify file targets name is [available here](./metadata/file-targets.sql).

- Identify all `<extended event session name>*.xel` files in the directory. There should be 5 at most, if you didn't change the default max number of files.
- Compress it using zip, 7-zip, etc. The compression ratio is important on these files.
- Grab files locally and open them using SQL Server Management Studio

## Session Scripts

See the individual .sql files in this directory for various Extended Events sessions including:
- auto-stats-create.sql - Track auto statistics updates
- blocked-processes-create/read.sql - Capture blocking events
- errors-create/read.sql - Monitor SQL Server errors
- implicit-conversion-create.sql - Track implicit conversions
- long-running-queries-create.sql - Capture slow queries
- recompilations-create.sql - Monitor query recompilations
- spills-to-tempdb-create.sql - Track tempdb spills
- And many more...

## Subdirectories

### 📁 [bugs-identification](./bugs-identification/)

Extended Events sessions to identify known SQL Server bugs.

### 📁 [management](./management/)

Scripts for managing Extended Events sessions and files.

### 📁 [metadata](./metadata/)

Scripts for querying Extended Events metadata and configuration.