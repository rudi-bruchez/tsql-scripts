-------------------------------------------------------------------------------------
-- Really unused indexes in the database. Look at the last server start date to 
-- evaluate index usage. Then use the last column DDL statement
-- to remove the indexes.
--
-- rudi@babaluga.com, go ahead license
-------------------------------------------------------------------------------------

;WITH size AS (
	SELECT s.[object_id], s.[index_id], 
		SUM(s.[used_page_count]) * 8 AS IndexSizeKB
	FROM sys.dm_db_partition_stats AS s
	GROUP BY s.[object_id], s.[index_id]
)
SELECT 
	(SELECT DATEDIFF(day, sqlserver_start_time, CURRENT_TIMESTAMP) FROM sys.dm_os_sys_info) as [Period_days],
	SCHEMA_NAME(t.schema_id) + '.' + OBJECT_NAME(ius.object_id) as tbl,
	i.name as idx, 
	CONCAT(STUFF((SELECT ', ' + c.name as [text()]
			FROM sys.index_columns ic
			JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
			WHERE ic.object_id = t.object_id AND ic.index_id = i.index_id
			AND ic.is_included_column = 0
			ORDER BY ic.key_ordinal
			FOR XML PATH('')), 1, 2, ''), ' (' +
		STUFF((SELECT ', ' + c.name as [text()]
			FROM sys.index_columns ic
			JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
			WHERE ic.object_id = t.object_id AND ic.index_id = i.index_id
			AND ic.is_included_column = 1
			ORDER BY ic.key_ordinal
			FOR XML PATH('')), 1, 2, '') + ')') as [key],
	i.type_desc as idxType,
	i.is_unique,
	i.is_primary_key,
	ius.user_updates, 
	CAST(ius.last_user_update AS DATETIME2(0)) as last_user_update,
	s.IndexSizeKB,
	SUM(s.IndexSizeKB) OVER () / 1024 as TotalSizeMB,
	CAST(SUM(ius.user_updates) OVER () * 1.0
		/ (SELECT DATEDIFF(minute, sqlserver_start_time, CURRENT_TIMESTAMP) FROM sys.dm_os_sys_info) as decimal(20, 2)) as Modifications_Per_Minute_Avg,
	'DROP INDEX [' + i.name + '] ON [' + SCHEMA_NAME(t.schema_id) + '].[' + OBJECT_NAME(ius.object_id) + ']'
FROM sys.dm_db_index_usage_stats ius
JOIN sys.indexes i ON ius.object_id = i.object_id AND ius.index_id = i.index_id
JOIN sys.tables t ON i.object_id = t.object_id
JOIN size s ON t.object_id = s.object_id AND i.index_id = s.index_id
WHERE database_id = DB_ID()
AND ius.user_seeks + ius.user_scans = 0 
AND i.is_primary_key = 0 AND i.is_unique = 0 AND i.type = 2 /* nonclustered */
ORDER BY tbl;