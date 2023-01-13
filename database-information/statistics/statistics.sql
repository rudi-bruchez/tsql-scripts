-------------------------------------------------------------------------------
-- Listing column statistics, ordered by columns to detect 
-- potential duplication in auto generated statistics in SQL Server 
-- rudi@babaluga.com, go ahead license
-------------------------------------------------------------------------------

DECLARE @tablename sysname = '%';
DECLARE @onlyAuto bit = 0; -- analyze only auto statistics

SELECT 
	CONCAT(QUOTENAME(SCHEMA_NAME(o.schema_id)), '.', 
		QUOTENAME(OBJECT_NAME(stat.object_id))) as tbl,
	stat.object_id,
	stat.name,
	c.name as column_name,
	CAST(sp.last_updated as datetime2(0)) as last_updated,  
	sp.rows, 
	sp.rows_sampled, 
	sp.steps, 
	sp.unfiltered_rows, 
	sp.modification_counter,
	CONCAT('UPDATE STATISTICS ', QUOTENAME(SCHEMA_NAME(o.schema_id)), '.', QUOTENAME(o.name),
        ' ', stat.name, ' WITH FULLSCAN'
    ) as update_ddl,
	CONCAT('DROP STATISTICS ', QUOTENAME(SCHEMA_NAME(o.schema_id)), '.', QUOTENAME(o.name),
        '.', QUOTENAME(stat.name), ';'
    ) as drop_ddl
FROM sys.stats AS stat
JOIN sys.stats_columns sc ON stat.object_id = sc.object_id AND stat.stats_id = sc.stats_id
JOIN sys.columns c ON sc.object_id = c.object_id AND sc.column_id = c.column_id
	AND sc.stats_column_id = 1
JOIN sys.objects o ON stat.object_id = o.object_id
CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp 
WHERE o.is_ms_shipped = 0
AND o.name LIKE @tablename
-- AND (stat.name LIKE '_WA_Sys_%' OR @onlyAuto = 0)
AND (stat.auto_created = 1 OR @onlyAuto = 0)
ORDER BY tbl, column_name, stat.name
OPTION (RECOMPILE, MAXDOP 1);