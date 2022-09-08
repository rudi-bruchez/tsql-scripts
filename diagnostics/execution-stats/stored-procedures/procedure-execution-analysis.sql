-----------------------------------------------------------------
-- Returns information about stored procedure execution in the
-- current database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	--DB_NAME(ps.database_id) as [db],
	CONCAT(OBJECT_SCHEMA_NAME(ps.object_id, ps.database_id), '.', OBJECT_NAME(ps.object_id, ps.database_id)) as [proc],
	CAST(ps.cached_time as datetime2(0)) as cached_time, 
	CAST(ps.last_execution_time as datetime2(0)) as last_execution_time,
	DATEDIFF(hour, ps.cached_time, ps.last_execution_time) as hours_in_cache,
	FORMAT(ps.execution_count, 'N0') as execution_count,
	ps.execution_count / COALESCE(NULLIF(DATEDIFF(hour, ps.cached_time, ps.last_execution_time), 0), 1) AS execution_per_hour,
	FORMAT(ps.last_logical_reads, 'N0') AS last_reads,
	FORMAT(ps.max_logical_reads, 'N0') AS max_reads,
	ps.total_worker_time / 1000 / 1000 AS total_worker_time_sec,
	CAST((CAST(ps.max_worker_time as bigint) / 1000) / 1000.0 as DECIMAL(10, 3)) AS max_worker_time_sec,
	CAST((CAST(ps.max_elapsed_time as bigint) / 1000) / 1000.0 as DECIMAL(10, 3)) AS max_elapsed_time_sec,
	qp.query_plan
FROM sys.dm_exec_procedure_stats ps
CROSS APPLY sys.dm_exec_query_plan(ps.plan_handle) qp
WHERE ps.database_id = DB_ID()
ORDER BY execution_per_hour DESC
OPTION (RECOMPILE, MAXDOP 1);