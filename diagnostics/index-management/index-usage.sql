-----------------------------------------------------------------
-- find index usage in the current database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT 
	SCHEMA_NAME(t.schema_id) + '.' + OBJECT_NAME(ius.object_id) as tbl,
	i.name as idx, 
	i.type_desc as idxType,
	i.is_unique,
	i.is_primary_key,
	user_seeks, 
	user_scans, 
	user_lookups, 
	user_updates, 
	last_user_seek, 
	last_user_scan, 
	last_user_lookup, 
	last_user_update, 
	system_seeks, 
	system_scans, 
	system_lookups, 
	system_updates, 
	last_system_seek, 
	last_system_scan, 
	last_system_lookup, 
	last_system_update 
FROM sys.dm_db_index_usage_stats ius
JOIN sys.indexes i ON ius.object_id = i.object_id AND ius.index_id = i.index_id
JOIN sys.tables t ON i.object_id = t.object_id
WHERE database_id = DB_ID()
ORDER BY tbl