# Migration

Scripts to prepare a migration or an upgrade to a newer SQL Server version.

## 📝 [deprecated-features](./deprecated-features.sql)

Lists the deprecated features used on the instance since its last restart, with their usage count, read from the `SQLServer:Deprecated Features` performance counters. Run it on an instance that has been up for a representative period before an upgrade. On a named instance the object name starts with `MSSQL$<name>:` and the filter must be edited; `TRIM` requires SQL Server 2017.
