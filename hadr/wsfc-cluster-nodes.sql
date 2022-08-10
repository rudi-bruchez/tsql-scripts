-----------------------------------------------------------------
-- WSFC cluster nodes
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	cn.*,
	cs.join_state_desc as join_state
FROM sys.dm_hadr_availability_replica_cluster_nodes cn
JOIN sys.dm_hadr_availability_replica_cluster_states cs 
    ON cn.replica_server_name = cs.replica_server_name
OPTION (RECOMPILE, MAXDOP 1);
