-------------------------------------------------------------------------------
-- Listing column statistics, ordered by columns to detect 
-- potential duplication in auto generated statistics in SQL Server 
-- for pre-2012 SQL Server
-- rudi@babaluga.com, go ahead license
-------------------------------------------------------------------------------

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