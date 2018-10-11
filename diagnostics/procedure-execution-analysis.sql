-----------------------------------------------------------------
-- Returns information about stored procedure 
-- execution in SQL Server
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

-- global
SELECT 
	OBJECT_NAME(ps.object_id) as procedure_name,
	ps.cached_time, 
	ps.last_execution_time,
	DATEDIFF(day, ps.cached_time, ps.last_execution_time) as days_in_cache,
	ps.execution_count,
	ps.execution_count / COALESCE(NULLIF(DATEDIFF(hour, ps.cached_time, ps.last_execution_time), 0), 1) AS execution_per_hour,
	ps.total_worker_time / 1000 / 1000 AS total_worker_time_sec,
	REPLACE(REPLACE((CONVERT(varchar, CONVERT(money, ps.last_logical_reads), 1)), ',', ' '), '.00', '') AS last_logical_reads,
	REPLACE(REPLACE((CONVERT(varchar, CONVERT(money, ps.max_logical_reads), 1)), ',', ' '), '.00', '') AS max_logical_reads,
	(CAST(ps.max_worker_time as bigint) / 1000) / 1000.0 / 60 AS max_worker_time_minutes,
	(CAST(ps.max_elapsed_time as bigint) / 1000) / 1000.0 / 60 AS max_elapsed_time_minutes,
	qp.query_plan,
	CAST(qp.query_plan as XML) as text_query_plan
FROM sys.dm_exec_procedure_stats ps
CROSS APPLY sys.dm_exec_query_plan(ps.plan_handle) qp
WHERE ps.database_id = DB_ID()
-- AND ps.object_id = OBJECT_ID('<PROCEDURE NAME>')
ORDER BY execution_per_hour DESC
OPTION (RECOMPILE);

-- detailed
SELECT 
	OBJECT_NAME(ps.object_id) as procedure_name,
	qs.plan_generation_num,
	qs.creation_time,
	qs.statement_start_offset,
	SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
      ((CASE qs.statement_end_offset
        WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset
      END - qs.statement_start_offset)/2) + 1) AS statement_text,
	(CAST(qs.max_elapsed_time as bigint) / 1000) / 1000.0 / 60 as statement_max_elapsed_time_minutes,
	ps.cached_time, 
	ps.last_execution_time,
	DATEDIFF(day, ps.cached_time, ps.last_execution_time) as days_in_cache,
	ps.execution_count,
	ps.execution_count / COALESCE(NULLIF(DATEDIFF(hour, ps.cached_time, ps.last_execution_time), 0), 1) AS execution_per_hour,
	ps.total_worker_time / 1000 / 1000 AS total_worker_time_sec,
	REPLACE(REPLACE((CONVERT(varchar, CONVERT(money, ps.last_logical_reads), 1)), ',', ' '), '.00', '') AS last_logical_reads,
	REPLACE(REPLACE((CONVERT(varchar, CONVERT(money, ps.max_logical_reads), 1)), ',', ' '), '.00', '') AS max_logical_reads,
	(CAST(ps.max_worker_time as bigint) / 1000) / 1000.0 / 60 AS max_worker_time_minutes,
	(CAST(ps.max_elapsed_time as bigint) / 1000) / 1000.0 / 60 AS max_elapsed_time_minutes,
	qp.query_plan,
	CAST(tqp.query_plan as XML) as text_query_plan
FROM sys.dm_exec_procedure_stats ps
JOIN sys.dm_exec_query_stats qs ON ps.sql_handle = qs.sql_handle
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
CROSS APPLY sys.dm_exec_text_query_plan(qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) tqp
WHERE ps.database_id = DB_ID()
AND ps.object_id = OBJECT_ID('<PROCEDURE NAME>')
OPTION (RECOMPILE);