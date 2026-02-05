# AWS RDS

Scripts for AWS RDS SQL Server instances.

## 📝 [create-alwayson-xevent](./create-alwayson-xevent.sql)

Creates an AlwaysOn Extended Events session for AWS RDS SQL Server. The default system AlwaysOn XEvent session is disabled by default in AWS RDS. This creates a user session named `urds_AlwaysOn_health` (cannot use `rds_` prefix as it's reserved) that captures availability group events, replica state changes, errors, and diagnostics. Output is stored in a file target on RDS storage.
