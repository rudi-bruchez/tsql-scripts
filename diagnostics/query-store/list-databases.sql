-- check is the query stor is enabled on some databases.
SELECT 
	d.name,
	d.database_id,
	d.create_date,
	d.state_desc as [state],
	rs.is_local,
	rs.is_primary_replica,
	rs.synchronization_state_desc as synchronization_state,
	rs.synchronization_health_desc as synchronization_health
FROM sys.databases d
LEFT JOIN sys.dm_hadr_database_replica_states rs ON d.database_id = rs.database_id
WHERE d.is_query_store_on = 1