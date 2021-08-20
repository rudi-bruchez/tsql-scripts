-----------------------------------------------------------------
-- Get index usage on a specific SQL Server table  
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
SELECT sqlserver_start_time 
FROM sys.dm_os_sys_info
OPTION (RECOMPILE, MAXDOP 1);
GO

DECLARE @table_name sysname = '%';

SELECT 
	SCHEMA_NAME(t.schema_id) + '.' + OBJECT_NAME(ius.object_id) as tbl,
	i.name as idx, 
	i.is_unique AS uq,
	user_seeks AS seeks, 
	user_scans AS scans, 
	user_updates AS updates, 
	CAST(last_user_seek AS DATETIME2(0)) AS last_seek, 
	CAST(last_user_scan AS DATETIME2(0)) AS last_scan, 
	CAST(last_user_update AS DATETIME2(0)) AS last_upd,
	FORMAT(ps.page_count * 8.192, 'N', 'fr-fr') as size_kb,
	ps.fragmentation AS [fragmentation %],
	i.index_id
FROM sys.dm_db_index_usage_stats ius
JOIN sys.indexes i ON ius.object_id = i.object_id AND ius.index_id = i.index_id
JOIN sys.tables t ON i.object_id = t.object_id
CROSS APPLY (SELECT SUM(page_count) as page_count, CAST(MAX(avg_fragmentation_in_percent) AS DECIMAL(5,2)) AS fragmentation FROM sys.dm_db_index_physical_stats(DB_ID(), i.object_id, i.index_id, NULL , N'LIMITED')) AS ps
WHERE ius.database_id = DB_ID()
AND t.name LIKE @table_name
-- AND user_seeks = 0
AND i.type_desc = N'NONCLUSTERED'
AND i.is_primary_key = 0
ORDER BY tbl, ps.page_count DESC
OPTION (RECOMPILE, MAXDOP 1);