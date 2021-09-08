SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	ag.name AS [AG Name], 
	ar.replica_server_name, 
	ags.primary_replica,
	CASE WHEN ar.replica_server_name = ags.primary_replica THEN 1 ELSE 0 END as is_primary,
	ar.availability_mode_desc, 
	adc.database_name,
    drs.is_local, 
    drs.database_state_desc as db_state,
	suspend_reason_desc as suspend_reason
FROM sys.dm_hadr_database_replica_states AS drs
JOIN sys.availability_databases_cluster AS adc ON drs.group_id = adc.group_id AND drs.group_database_id = adc.group_database_id
JOIN sys.availability_groups AS ag ON ag.group_id = drs.group_id
JOIN sys.availability_replicas AS ar ON drs.group_id = ar.group_id AND drs.replica_id = ar.replica_id
JOIN sys.dm_hadr_availability_group_states ags ON ag.group_id = ags.group_id
ORDER BY ag.name, ar.replica_server_name, adc.database_name 
OPTION (RECOMPILE, MAXDOP 1);
