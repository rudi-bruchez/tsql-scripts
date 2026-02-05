# HADR (High Availability and Disaster Recovery)

Scripts for AlwaysOn Availability Groups, Failover Clustering, and Log Shipping management.

## 📝 [alwayson-statuts](./alwayson-statuts.sql)

Collection of queries to inspect AlwaysOn Availability Groups metadata and status including endpoints, permissions, databases in the AG, and cluster states.

## 📝 [auto-repaired-pages](./auto-repaired-pages.sql)

Lists pages that were automatically repaired by AlwaysOn from a healthy replica. Useful for identifying past corruption events that were auto-healed.

## 📝 [availability-groups](./availability-groups.sql)

Shows Availability Group metadata including failure condition level, health check timeout, backup preferences, and synchronization health.

## 📝 [availability-replicas](./availability-replicas.sql)

Lists all availability replicas with configuration details: availability mode, failover mode, seeding mode, session timeout, connection settings, and routing URLs.

## 📝 [availability-replicas-states](./availability-replicas-states.sql)

Shows current state of availability replicas including role, operational state, connection state, recovery health, and synchronization health.

## 📝 [database-replica-states](./database-replica-states.sql)

Comprehensive view of database replica states showing synchronization state, suspend status, send/receive/hardened/redone times, queue sizes, and lag metrics.

## 📝 [database-status-for-sql2012](./database-status-for-sql2012.sql)

Database status query compatible with SQL Server 2012 AlwaysOn.

## 📝 [failover-times](./failover-times.sql)

Determines AG failover times by reading error 1480 from the AlwaysOn Extended Events files. Useful for auditing failover history.

## 📝 [failover-times-aggregated](./failover-times-aggregated.sql)

Aggregated view of failover times from Extended Events.

## 📝 [latency](./latency.sql)

Measures secondary replica latency showing send/hardened/redone times, queue sizes, send and redo rates, and secondary lag in seconds.

## 📝 [lease-expired-from-errorlog](./lease-expired-from-errorlog.sql)

Searches error log for lease expiration events that may indicate cluster issues.

## 📝 [listeners](./listeners.sql)

Lists AG listener information including DNS name, port, IP addresses, subnet masks, and DHCP configuration.

## 📝 [log-shipping-metadata](./log-shipping-metadata.sql)

Shows Log Shipping configuration for both secondary and primary databases including backup directories, last files, and dates.

## 📝 [lost-connection-with-secondary-from-errorlog](./lost-connection-with-secondary-from-errorlog.sql)

Searches error log for lost connection events with secondary replicas.

## 📝 [read-only-routing](./read-only-routing.sql)

Displays read-only routing configuration showing which replicas handle read-only connections and their routing priority.

## 📝 [redo-states](./redo-states.sql)

Information on REDO operations on secondary replicas including queue size, synchronization state, suspend status, and delay since last redo.

## 📝 [secondary-synchronization-lag](./secondary-synchronization-lag.sql)

Measures synchronization lag between primary and secondary replicas showing lag in seconds, redo queue size, redo rate, and estimated time to catch up.

## 📝 [who-is-principal](./who-is-principal.sql)

Identifies which replica is currently the primary/principal.

## 📝 [wsfc-cluster](./wsfc-cluster.sql)

Shows Windows Server Failover Cluster (WSFC) information including cluster name, quorum type, and quorum state.

## 📝 [wsfc-cluster-networks](./wsfc-cluster-networks.sql)

WSFC cluster network configuration.

## 📝 [wsfc-cluster-nodes](./wsfc-cluster-nodes.sql)

Lists WSFC cluster nodes and their states.

## 📝 [wsfc-cluster-state](./wsfc-cluster-state.sql)

Shows overall WSFC cluster state.

## 📝 [xevent-redo-waits-create](./xevent-redo-waits-create.sql)

Creates an Extended Events session to capture redo wait events for troubleshooting secondary lag.

## 📝 [xevent-redo-waits-read](./xevent-redo-waits-read.sql)

Reads and analyzes the redo waits Extended Events session.

## Subdirectories

### 📁 [automatic-seeding](./automatic-seeding/)

Scripts for monitoring and managing automatic seeding operations.

### 📁 [functions](./functions/)

Reusable functions for HADR monitoring.

### 📁 [maintenance](./maintenance/)

Maintenance scripts for AG environments.
