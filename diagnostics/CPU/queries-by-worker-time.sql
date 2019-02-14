SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @cpu_count int;

SELECT 
	@cpu_count = cpu_count
FROM sys.dm_os_sys_info
OPTION (RECOMPILE);

SELECT TOP(50) 
	DB_NAME(t.[dbid]) AS [Database Name], 
	COALESCE('proc : ' + OBJECT_NAME(t.objectid, t.[dbid]), LTRIM(REPLACE(REPLACE(LEFT(t.[text], 255), CHAR(10),''), CHAR(13),''))) as proc_or_query,
	qs.execution_count AS [Execution Count],
	datediff(millisecond, qs.creation_time, current_timestamp) as sample_time_ms,
	qs.total_worker_time / 1000 AS [Total Worker Time ms], 
	(100 * (qs.total_worker_time / 1000 / @cpu_count)) / datediff(millisecond, qs.creation_time, current_timestamp) AS [% Worker Time Absolute], 
	--(100 * qs.total_worker_time) / SUM(qs.total_worker_time) OVER () AS [% Worker Time Relative], 
	qs.min_worker_time AS [Min Worker Time],
	qs.total_worker_time/qs.execution_count AS [Avg Worker Time], 
	qs.max_worker_time AS [Max Worker Time], 
	qs.min_elapsed_time AS [Min Elapsed Time], 
	qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time], 
	qs.max_elapsed_time AS [Max Elapsed Time],
	qs.min_logical_reads AS [Min Logical Reads],
	qs.total_logical_reads/qs.execution_count AS [Avg Logical Reads],
	qs.max_logical_reads AS [Max Logical Reads], 
	CASE WHEN CONVERT(nvarchar(max), qp.query_plan) LIKE N'%<MissingIndexes>%' THEN 1 ELSE 0 END AS [Has Missing Index], 
	qs.creation_time AS [Creation Time]
	--,t.[text] AS [Query Text], qp.query_plan AS [Query Plan] -- uncomment out these columns if not copying results to Excel
FROM sys.dm_exec_query_stats AS qs
OUTER APPLY sys.dm_exec_sql_text(plan_handle) AS t 
OUTER APPLY sys.dm_exec_query_plan(plan_handle) AS qp 
ORDER BY qs.total_worker_time DESC OPTION (RECOMPILE);