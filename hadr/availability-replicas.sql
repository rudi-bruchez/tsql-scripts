-----------------------------------------------------------------
-- availability replicas metadata
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	g.name as AG,
	ar.replica_server_name,
	ar.availability_mode_desc as [availability_mode],
	ar.failover_mode_desc as [failover_mode],
	ar.session_timeout,
	ar.primary_role_allow_connections_desc as [primary_role_allow_connections],
	ar.secondary_role_allow_connections_desc as [secondary_role_allow_connections],
	CAST(ar.create_date as datetime2(0)) as create_date,
	CAST(ar.modify_date as datetime2(0)) as modify_date,
	ar.backup_priority,
	ar.read_only_routing_url
FROM sys.availability_replicas ar
JOIN sys.availability_groups g ON ar.group_id = g.group_id
ORDER BY g.name, ar.replica_server_name
OPTION (RECOMPILE, MAXDOP 1);
