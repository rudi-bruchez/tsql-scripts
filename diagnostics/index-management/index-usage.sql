-----------------------------------------------------------------
-- find index usage in the current database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

;WITH size AS (
	SELECT s.[object_id], s.[index_id], 
		SUM(s.[used_page_count]) * 8 AS IndexSizeKB
	FROM sys.dm_db_partition_stats AS s
	GROUP BY s.[object_id], s.[index_id]
)
SELECT 
	SCHEMA_NAME(t.schema_id) + '.' + OBJECT_NAME(ius.object_id) as tbl,
	i.name as idx, 
	i.type_desc as idxType,
	i.is_unique,
	i.is_primary_key,
	ius.user_seeks, 
	ius.user_scans, 
	ius.user_updates, 
	ius.last_user_seek, 
	ius.last_user_scan, 
	ius.last_user_update,
	s.IndexSizeKB
FROM sys.dm_db_index_usage_stats ius
JOIN sys.indexes i ON ius.object_id = i.object_id AND ius.index_id = i.index_id
JOIN sys.tables t ON i.object_id = t.object_id
JOIN size s ON t.object_id = s.object_id AND i.index_id = s.index_id
WHERE database_id = DB_ID()
--AND t.name = N'TABLE_NAME'
ORDER BY tbl;

-----------------------------------------------------------------
-- Get index usage on a specific SQL Server table  
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

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
	i.index_id
FROM sys.dm_db_index_usage_stats ius
JOIN sys.indexes i ON ius.object_id = i.object_id AND ius.index_id = i.index_id
JOIN sys.tables t ON i.object_id = t.object_id
CROSS APPLY (SELECT SUM(page_count) as page_count FROM sys.dm_db_index_physical_stats(DB_ID(), i.object_id, i.index_id, NULL , N'LIMITED')) AS ps
WHERE ius.database_id = DB_ID()
AND ius.object_id = OBJECT_ID('<TABLE NAME>')
-- AND user_seeks = 0
AND i.type_desc = N'NONCLUSTERED'
AND i.is_primary_key = 0
ORDER BY tbl, ps.page_count DESC;