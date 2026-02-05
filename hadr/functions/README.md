# HADR Functions

Reusable T-SQL functions for HADR monitoring.

## 📝 [fn_hadr_synchronization_lag](./fn_hadr_synchronization_lag.sql)

Returns the synchronization lag in seconds between primary and secondary replicas for a specified database. Calculated as the difference between last hardened time and last redone time. Useful for monitoring and alerting on replica lag.
