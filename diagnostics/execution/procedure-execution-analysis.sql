-----------------------------------------------------------------
-- Returns information about stored procedure 
-- execution in SQL Server
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

-- global
SELECT 
	DB_NAME(ps.database_id) as [db],
	CONCAT(OBJECT_SCHEMA_NAME(ps.object_id, ps.database_id), '.', OBJECT_NAME(ps.object_id, ps.database_id)) as [proc],
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

-- proc analysis
SELECT 
	DB_NAME(ps.database_id) as [DB],
	object_name(ps.object_id) as [proc], 
	CAST(ps.cached_time as DATETIME2(0)) as cached_time, 
	CAST(ps.last_execution_time as DATETIME2(0)) as last_execution_time, 
	ps.execution_count, 
	ps.execution_count / NULLIF(DATEDIFF(hour, ps.cached_time, ps.last_execution_time), 0) as average_execution_per_hour, 
	ps.min_worker_time / 1000 as min_cpu_time_ms,
	ps.max_worker_time / 1000 as max_cpu_time_ms,
	ps.min_logical_reads as min_reads,
	ps.max_logical_reads as max_reads,
	ps.min_elapsed_time / 1000 as min_execution_time_ms,
	ps.max_elapsed_time / 1000 as max_execution_time_ms
FROM sys.dm_exec_procedure_stats ps
WHERE object_name(ps.object_id) NOT LIKE N'sp_%'
-- AND ps.database_id = DB_ID() -- current DB only
ORDER BY average_execution_per_hour DESC;

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