-----------------------------------------------------------------
-- Returns information about stored procedure 
-- execution in SQL Server
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

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
ORDER BY execution_per_hour DESC
OPTION (RECOMPILE, MAXDOP 1);