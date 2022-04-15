# Extended Event sessions

Extended event sessions to track events on on-prem SQL Server instances.

## How to get session events

If you are using the "event file" target, the session files will usually by in the `log` directory of SQL Server. 

You can find this directory by using [this query](/server-information/get-sqlserver-log-directory.sql)

A more complete query to identify file targets name is [available here](./metadata/file-targets.sql).

- Identify all `<extended event session name>*.xel` files in the directory. There should be 5 at most, if you didn't change the default max number of files. 
- Compress it using zip, 7-zip, etc. The compression ratio is important on these files.
- Grab files locally and open them using Sql Server Management Studio