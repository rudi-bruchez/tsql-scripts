-----------------------------------------------------------------
-- performance analysis of parallelized queries
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT TOP 100
	DB_NAME(st.dbid) as db,
	qs.execution_count,
	qs.total_logical_reads / qs.execution_count as average_logical_reads,
	qs.total_worker_time /1000 / qs.execution_count as average_worker_time_ms,
	qs.last_rows,
	st.text, 
	qp.query_plan, 
	qs.creation_time,
	DATEDIFF(hour, qs.creation_time, qs.last_execution_time) as trace_duration_hours,
	CAST (CAST (qs.execution_count AS DECIMAL (10, 2)) / COALESCE(NULLIF(DATEDIFF(hour, qs.creation_time, qs.last_execution_time), 0), 1) AS DECIMAL (10, 2)) as avg_calls_per_hour,
	qs.last_execution_time, 
	qs.last_worker_time / 1000 as last_worker_time_ms,
	qs.min_worker_time / 1000 as min_worker_time_ms,
	qs.max_worker_time / 1000 as max_worker_time_ms,
	qs.last_elapsed_time / 1000 as last_elapsed_time_ms,
	qs.min_elapsed_time / 1000 as min_elapsed_time_ms,
	qs.max_elapsed_time / 1000 as max_elapsed_time_ms,
	qs.min_dop,
	qs.max_dop,
	qs.last_dop
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE qs.execution_count > 1
--AND st.dbid IS NOT NULL AND st.dbid <> 32767 -- resource 
AND st.dbid = DB_ID() -- only the current database
AND qs.max_dop > 1
ORDER BY qs.max_dop DESC, average_logical_reads DESC
OPTION (RECOMPILE, MAXDOP 1);