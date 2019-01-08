---------------------------------------------------------------------------------------------------------------------------
-- find queries using index scans
--
-- rudi@babaluga.com, go ahead license
-- code adapted from https://stackoverflow.com/questions/2247713/how-to-find-what-stored-procedures-are-using-what-indexes
---------------------------------------------------------------------------------------------------------------------------

WITH xmlnamespaces ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS sp)
, cte AS (
	SELECT TOP(100) 
	  q.total_logical_reads, q.execution_count
	  , x.value(N'@Database', N'sysname') AS [Database]
	  , x.value(N'@Schema', N'sysname') + N'.' + x.value(N'@Table', N'sysname') AS [Table]
	  , x.value(N'@Index', N'sysname') AS [Index]
	  , substring(t.text, q.statement_start_offset/2,   
	  CASE WHEN 0 < q.statement_end_offset THEN (q.statement_end_offset - q.statement_start_offset)/2
	  ELSE len(t.text) - q.statement_start_offset/2 END) AS [Statement]
	FROM sys.dm_exec_query_stats q
	CROSS APPLY sys.dm_exec_query_plan(plan_handle)
	CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS t
	CROSS APPLY query_plan.nodes(N'//sp:IndexScan/sp:Object') s(x)
)
SELECT *
FROM cte
WHERE [Database] = QUOTENAME(DB_NAME())
--AND [Table] = N'TABLE_NAME';