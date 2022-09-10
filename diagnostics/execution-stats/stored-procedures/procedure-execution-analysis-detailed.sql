-----------------------------------------------------------------
-- Returns detailed information about one stored procedure 
-- execution
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @procedureName sysname = N'<PROCEDURE NAME HERE>'

SELECT 
	OBJECT_NAME(ps.object_id) as proc_name,
	qs.plan_generation_num as plan_num,
    CAST(qs.creation_time as datetime2(0)) as creation_time,
	qs.statement_start_offset as [offset],
	SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
      ((CASE qs.statement_end_offset
        WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset
      END - qs.statement_start_offset)/2) + 1) AS stmt_text,
    CAST((CAST(qs.max_elapsed_time as bigint) / 1000.0) as numeric(18,2)) as stmt_max_exec_time_ms,
    CAST(ps.cached_time as datetime2(0)) as cached_time,
    CAST(ps.last_execution_time as datetime2(0)) as last_exec_time,
	DATEDIFF(day, ps.cached_time, ps.last_execution_time) as days_in_cache,
	ps.execution_count as exec_count,
	ps.execution_count / COALESCE(NULLIF(DATEDIFF(hour, ps.cached_time, ps.last_execution_time), 0), 1) AS exec_per_hour,
	ps.total_worker_time / 1000 AS total_worker_time_ms,
	REPLACE(REPLACE((CONVERT(varchar, CONVERT(money, ps.last_logical_reads), 1)), ',', ' '), '.00', '') AS last_logical_reads,
	REPLACE(REPLACE((CONVERT(varchar, CONVERT(money, ps.max_logical_reads), 1)), ',', ' '), '.00', '') AS max_logical_reads,
    CAST((CAST(ps.max_worker_time as bigint) / 1000.0) as numeric(18,2)) as max_worker_time_ms,
    CAST((CAST(ps.max_elapsed_time as bigint) / 1000.0) as numeric(18,2)) as max_exec_time_ms,
	qp.query_plan as proc_query_plan,
	CAST(tqp.query_plan as XML) as stmt_query_plan
FROM sys.dm_exec_procedure_stats ps
JOIN sys.dm_exec_query_stats qs ON ps.sql_handle = qs.sql_handle
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
CROSS APPLY sys.dm_exec_text_query_plan(qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) tqp
WHERE ps.database_id = DB_ID()
AND ps.object_id = OBJECT_ID(@procedureName)
OPTION (RECOMPILE, MAXDOP 1);