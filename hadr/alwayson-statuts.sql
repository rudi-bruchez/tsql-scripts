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
-- 1. WSFC Cluster information
-----------------------------------------------------------------
SELECT 
	c.cluster_name,
	c.quorum_type_desc as quorum_type,
	c.quorum_state_desc as quorum_state
FROM sys.dm_hadr_cluster c

-- cluster nodes
SELECT 
	cn.*,
	cs.join_state_desc as join_state
FROM sys.dm_hadr_availability_replica_cluster_nodes cn
JOIN sys.dm_hadr_availability_replica_cluster_states cs ON cn.replica_server_name = cs.replica_server_name


-- cluster networks
SELECT *
FROM sys.dm_hadr_cluster_networks

-- state of the cluster
SELECT 
	cm.member_name,
	cm.member_type_desc as member_type,
	cm.member_state_desc as member_state,
	cm.number_of_quorum_votes
FROM sys.dm_hadr_cluster_members cm;

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
-- 3. AlwaysOn AG information
-----------------------------------------------------------------
-- group
SELECT 
	g.name,
	g.failure_condition_level,
	g.health_check_timeout,
	g.automated_backup_preference_desc as [automated_backup_preference],
	gs.primary_recovery_health_desc as [primary_health],
	gs.primary_replica,
	gs.secondary_recovery_health_desc as [secondary_health],
	gs.synchronization_health_desc as [synchronization_health]
FROM sys.availability_groups g
JOIN sys.dm_hadr_availability_group_states gs ON g.group_id = gs.group_id

-- replicas
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
ORDER BY g.name, ar.replica_server_name;

-- replica states
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
ORDER BY g.name, ar.replica_server_name, rs.role;

-- listeners
SELECT 
	g.name as AG, 
	agl.dns_name, 
	agl.is_conformant, 
	agl.port, 
	agl.ip_configuration_string_from_cluster,
	aglip.ip_address,
	aglip.ip_subnet_mask,
	aglip.is_dhcp,
	aglip.network_subnet_ip,
	aglip.network_subnet_ipv4_mask,
	aglip.network_subnet_prefix_length,
	aglip.state_desc
FROM sys.availability_group_listeners agl
JOIN sys.availability_group_listener_ip_addresses aglip ON agl.listener_id = aglip.listener_id
JOIN sys.availability_groups g ON agl.group_id = g.group_id
ORDER BY g.name, agl.dns_name;

-- read only routing
SELECT 
	g.name as AG,
	ar.replica_server_name as [Replica],
	ar2.replica_server_name as ReadOnly_Replica,
	rorl.routing_priority
FROM sys.availability_read_only_routing_lists rorl
JOIN sys.availability_replicas ar ON rorl.replica_id = ar.replica_id
LEFT JOIN sys.availability_replicas ar2 ON rorl.read_only_replica_id = ar2.replica_id
JOIN sys.availability_groups g ON ar.group_id = g.group_id
ORDER BY g.name, ar.replica_server_name;

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

-- pages auto-repaired ?
SELECT 
	DB_NAME(apr.database_id) as [database],
	apr.file_id,
	apr.page_id,
	apr.error_type,
	apr.page_status,
	apr.modification_time
FROM sys.dm_hadr_auto_page_repair apr
ORDER BY [database];