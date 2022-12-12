-----------------------------------------------------------------
-- Finds duplicate statistics on a table, because an auto stats
-- was created on a column that was indexed later on.
-- Generates a DROP STATISTICS statement for the auto stats
-- in the DDL column.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

;WITH index_stats AS (
	SELECT 
		MIN(CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(stat.object_id)), '.', QUOTENAME(OBJECT_NAME(stat.object_id)))) as tbl,
		stat.object_id,
		MIN(stat.name) as name,
		MIN(c.name) as column_name,
		c.column_id
	FROM sys.stats AS stat
	JOIN sys.stats_columns sc ON stat.object_id = sc.object_id AND stat.stats_id = sc.stats_id
	JOIN sys.columns c ON sc.object_id = c.object_id AND sc.column_id = c.column_id
		AND sc.stats_column_id = 1
	JOIN sys.objects o ON stat.object_id = o.object_id
	WHERE o.is_ms_shipped = 0
	AND stat.auto_created = 0
	GROUP BY stat.object_id, c.column_id
),
auto_stats AS (
	SELECT 
		stat.object_id,
		stat.name,
		c.name as column_name,
		c.column_id
	FROM sys.stats AS stat
	JOIN sys.stats_columns sc ON stat.object_id = sc.object_id AND stat.stats_id = sc.stats_id
	JOIN sys.columns c ON sc.object_id = c.object_id AND sc.column_id = c.column_id
		AND sc.stats_column_id = 1
	JOIN sys.objects o ON stat.object_id = o.object_id
	WHERE o.is_ms_shipped = 0
	AND stat.auto_created = 1
	AND NOT EXISTS ( -- forget about multi-columns stats
		SELECT * 
		FROM sys.stats_columns sc2 
		WHERE stat.object_id = sc.object_id 
		AND stat.stats_id = sc2.stats_id
		AND sc2.stats_column_id > 1
	)
)
SELECT index_stats.tbl, index_stats.column_name, index_stats.name, auto_stats.name,
	CONCAT('On the table ', index_stats.tbl, ', the column ', QUOTENAME(index_stats.column_name), 
	       ' has already statistics on the index ', QUOTENAME(index_stats.name), 
		   '. The statistics ', auto_stats.name, ' can be dropped.') as [description],
	CONCAT('DROP STATISTICS ', index_stats.tbl, '.', QUOTENAME(auto_stats.name)) as [DDL]
FROM index_stats 
JOIN auto_stats ON index_stats.object_id = auto_stats.object_id
                AND index_stats.column_id = auto_stats.column_id
OPTION (RECOMPILE, MAXDOP 1);