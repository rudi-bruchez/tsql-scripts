-----------------------------------------------------------------
-- Show user created statistics
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

;WITH cte AS (
SELECT 
	MIN(CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(stat.object_id)), '.', 
        QUOTENAME(OBJECT_NAME(stat.object_id)))) as tbl,
	stat.object_id,
	stat.stats_id,
	MIN(stat.name) as stat_name,
	STRING_AGG(c.name, ',') WITHIN GROUP ( ORDER BY sc.column_id ) as cols
FROM sys.stats AS stat
JOIN sys.stats_columns sc ON stat.object_id = sc.object_id AND stat.stats_id = sc.stats_id
JOIN sys.columns c ON sc.object_id = c.object_id AND sc.column_id = c.column_id
JOIN sys.objects o ON stat.object_id = o.object_id
WHERE o.is_ms_shipped = 0
AND stat.auto_created = 0
AND stat.user_created = 1
GROUP BY stat.object_id, stat.stats_id
)
SELECT 
    *,
	CONCAT('DROP STATISTICS ', tbl, '.', QUOTENAME(stat_name)) as [DDL]
FROM cte
ORDER BY tbl, stat_name
OPTION (RECOMPILE, MAXDOP 1);