-----------------------------------------------------------------
-- Collection of queries to inspect AlawysOn Availability Groups 
-- metadata and status 

-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

-----------------------------------------------------------------
-- AlwaysOn metadata and health queries
-- Rudi Bruchez - rudi@babaluga.com - 2017.03.10 - version 01
-----------------------------------------------------------------

-----------------------------------------------------------------
-- 2. Endpoints information
-----------------------------------------------------------------
SELECT type_desc, port 
FROM sys.tcp_endpoints  
WHERE type_desc = 'DATABASE_MIRRORING';

SELECT * 
FROM sys.dm_tcp_listener_states
WHERE type_desc = 'DATABASE_MIRRORING';

SELECT type_desc, state_desc, role_desc, is_encryption_enabled
FROM sys.database_mirroring_endpoints;

-- endpoint permissions  
SELECT 
	e.name, 
	sp.state,   
	SUSER_NAME(SP.grantor_principal_id) as grantor,
	sp.type as permission,  
	SUSER_NAME(SP.grantee_principal_id) as grantee   
FROM sys.server_permissions sp
JOIN sys.endpoints e ON sp.major_id = e.endpoint_id  
WHERE e.type_desc = 'DATABASE_MIRRORING'
ORDER BY permission, grantor, grantee;   
GO

-----------------------------------------------------------------
-- 4. databases information
-----------------------------------------------------------------
SELECT 
	g.name as AG,
	dc.database_name,
	dc.truncation_lsn
FROM sys.availability_databases_cluster dc
JOIN sys.availability_groups g ON dc.group_id = g.group_id
ORDER BY g.name, dc.database_name;

-- databases joined
SELECT
	g.name as AG,
	ar.replica_server_name as [Replica],
	rcs.database_name,
	rcs.is_database_joined,
	rcs.is_failover_ready,
	rcs.is_pending_secondary_suspend,
	rcs.truncation_lsn
FROM sys.dm_hadr_database_replica_cluster_states rcs
JOIN sys.availability_replicas ar ON rcs.replica_id = ar.replica_id
JOIN sys.availability_groups g ON ar.group_id = g.group_id
ORDER BY g.name, ar.replica_server_name, rcs.database_name;
