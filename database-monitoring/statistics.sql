-------------------------------------------------------------------------------
-- Listing potential duplication in auto generated statistics in SQL Server 
-- rudi@babaluga.com, go ahead license
-------------------------------------------------------------------------------
SELECT 
	OBJECT_NAME(stat.object_id) as tbl,
	stat.object_id,
	stat.name,
	c.name as column_name,
	CAST(sp.last_updated as datetime2(0)) as last_updated,  
	sp.rows, 
	sp.rows_sampled, 
	sp.steps, 
	sp.unfiltered_rows, 
	sp.modification_counter
FROM sys.stats AS stat
JOIN sys.stats_columns sc ON stat.object_id = sc.object_id AND stat.stats_id = sc.stats_id
JOIN sys.columns c ON sc.object_id = c.object_id AND sc.column_id = c.column_id
	AND sc.stats_column_id = 1
JOIN sys.objects o ON stat.object_id = o.object_id
CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp 
WHERE o.is_ms_shipped = 0
AND stat.object_id = OBJECT_ID('<TABLE NAME>') -- remove this line if you want a result for the whole database
AND stat.name LIKE '_WA_Sys_%'
ORDER BY tbl, column_name, stat.name;