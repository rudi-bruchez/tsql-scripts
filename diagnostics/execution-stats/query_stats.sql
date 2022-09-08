-----------------------------------------------------------------
-- Use dm_exec_query_stats to get the heaviest queries 
-- in the plan cache 
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT TOP 100
	DB_NAME(st.dbid) as db,
	qs.execution_count,
	qs.total_logical_reads / qs.execution_count as average_logical_reads,
	CAST(qs.total_worker_time / qs.execution_count / 1000.0 as numeric(18, 2)) as avg_worker_time_ms,
	qs.last_rows,
	-- REPLACE(REPLACE(st.text, '-', ''), '*', '') as [text], -- some random cleaning. the sql text often starts with long comment lines.
	st.text,
	qp.query_plan, 
	CAST(qs.creation_time as datetime2(0)) as creation_time, 
	CAST(qs.last_execution_time as datetime2(0)) as last_exec_time, 
	qs.execution_count / ISNULL(NULLIF(DATEDIFF(hour, qs.creation_time, qs.last_execution_time), 0), 1) AS exec_per_hour,
	CAST(qs.total_worker_time / 1000.0 as numeric(18, 2))  as total_worker_t_ms,
	CAST(qs.last_worker_time / 1000.0 as numeric(18, 2))   as last_worker_t_ms,
	CAST(qs.min_worker_time / 1000.0 as numeric(18, 2))    as min_worker_t_ms,
	CAST(qs.max_worker_time / 1000.0 as numeric(18, 2))    as max_worker_t_ms,
	CAST(qs.total_elapsed_time / 1000.0 as numeric(18, 2)) as total_elapsed_t_ms,
	CAST(qs.last_elapsed_time / 1000.0 as numeric(18, 2))  as last_elapsed_t_ms,
	CAST(qs.min_elapsed_time / 1000.0 as numeric(18, 2))   as min_elapsed_t_ms,
	CAST(qs.max_elapsed_time / 1000.0 as numeric(18, 2))   as max_elapsed_t_ms,
	qs.total_logical_reads,
	qs.last_logical_reads,
	qs.min_logical_reads,
	qs.max_logical_reads,
	qs.total_logical_writes,
	qs.last_logical_writes,
	qs.min_logical_writes,
	qs.max_logical_writes,
	qs.min_rows,
	qs.max_rows,
	qs.last_rows
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE qs.execution_count > 1
--AND st.dbid IS NOT NULL AND st.dbid <> 32767 -- resource
-- TODO - find a way to use spool_id from cached plans to filter out the internal pool (1)

-- queries executed on the last 24 hours
AND qs.last_execution_time >= DATEADD(day, -1, CURRENT_TIMESTAMP)
-- queries executed on the last hour
-- AND qs.last_execution_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP)


-- *** only the current database ***
--AND st.dbid = DB_ID()

-- *** do not take night batches into account ***
-- AND CAST(qs.last_execution_time as time) BETWEEN '08:00:00' AND '21:00:00' 
ORDER BY average_logical_reads DESC
OPTION (RECOMPILE, MAXDOP 1);