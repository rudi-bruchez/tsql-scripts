# HADR Maintenance

Maintenance scripts for AlwaysOn Availability Group environments.

## 📝 [agent-jobs](./agent-jobs.sql)

Code snippet to add as the first step of SQL Agent jobs in an AG environment. Checks if the current replica is primary using `sys.fn_hadr_is_primary_replica()` and throws an error to stop the job if running on a secondary. Ensures jobs only execute on the primary replica.

## 📝 [alert-on-lost-connection-with-secondary](./alert-on-lost-connection-with-secondary.sql)

Creates an alert to notify when connection is lost with a secondary replica.
