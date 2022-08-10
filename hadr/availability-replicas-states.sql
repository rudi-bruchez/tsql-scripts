-----------------------------------------------------------------
-- availability replicas states
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
	g.name as AG,
	ar.replica_server_name as [Replica],
	rs.is_local,
	rs.role_desc as role,
	rs.operational_state_desc as operational_state,
	rs.connected_state_desc as connected_state,
	rs.recovery_health_desc as recovery_health,
	rs.synchronization_health_desc as synchronization_health
FROM sys.dm_hadr_availability_replica_states rs
JOIN sys.availability_replicas ar ON rs.replica_id = ar.replica_id
JOIN sys.availability_groups g ON ar.group_id = g.group_id
ORDER BY g.name, ar.replica_server_name, rs.role
OPTION (RECOMPILE, MAXDOP 1);