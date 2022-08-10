-----------------------------------------------------------------
-- read only routing information
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	g.name as AG,
	ar.replica_server_name as [Replica],
	ar2.replica_server_name as ReadOnly_Replica,
	rorl.routing_priority
FROM sys.availability_read_only_routing_lists rorl
JOIN sys.availability_replicas ar ON rorl.replica_id = ar.replica_id
LEFT JOIN sys.availability_replicas ar2 ON rorl.read_only_replica_id = ar2.replica_id
JOIN sys.availability_groups g ON ar.group_id = g.group_id
ORDER BY g.name, ar.replica_server_name
OPTION (RECOMPILE, MAXDOP 1);