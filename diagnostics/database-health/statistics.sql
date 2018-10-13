-------------------------------------------------------------------------------
-- Listing column statistics, ordered by columns to detect 
-- potential duplication in auto generated statistics in SQL Server 
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

-- for pre-2012 SQL Server
;WITH cte AS (
	SELECT
       OBJECT_NAME(i.id) as [table],
       i.name as [stats],
       CAST(STATS_DATE(i.id, i.indid) as DATETIME2(0)) as [last update],
	   (SELECT SUM(rows) FROM sys.partitions p WHERE p.object_id = i.id AND p.object_id < 2) as [rows],
       i.rowmodctr as modifications,
       STUFF((SELECT ', ' + c.name as [text()]
       FROM sys.stats_columns sc
       JOIN sys.columns c ON sc.object_id = c.object_id AND sc.column_id = c.column_id
       WHERE sc.object_id = i.id AND sc.stats_id = i.indid
       ORDER BY sc.stats_column_id
       FOR XML PATH ('')), 1, 2, '') as [columns],
       CAST(SYSDATETIME() as DATETIME2(0)) as [now],
       DATEDIFF(hour, CAST(STATS_DATE(i.id, i.indid) as DATETIME2(0)), CAST(SYSDATETIME() as DATETIME2(0))) as hours
	FROM sys.sysindexes i
	JOIN sys.tables t ON i.id = t.object_id
	JOIN sys.stats st ON st.object_id = i.id AND st.stats_id = i.indid
	WHERE STATS_DATE(i.id, i.indid)<=DATEADD(DAY,-1,GETDATE())
	AND i.rowmodctr > 0
	AND t.is_ms_shipped = 0
)
SELECT *,
	100 * modifications / NULLIF([rows], 0) as [%] 
FROM cte
ORDER BY modifications DESC;