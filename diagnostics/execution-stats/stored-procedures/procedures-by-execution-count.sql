-----------------------------------------------------------------
-- List of most executed stored procedures in the current db
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	DB_NAME(ps.database_id) as [DB],
	object_name(ps.object_id) as [proc], 
	CAST(ps.cached_time as DATETIME2(0)) as cached_time, 
	CAST(ps.last_execution_time as DATETIME2(0)) as last_exec_time, 
	ps.execution_count as exec_count, 
	ps.execution_count / NULLIF(DATEDIFF(hour, ps.cached_time, ps.last_execution_time), 0) as avg_exec_per_hour, 
	ps.min_worker_time / 1000 as min_cpu_time_ms,
	ps.max_worker_time / 1000 as max_cpu_time_ms,
	ps.min_logical_reads as min_reads,
	ps.max_logical_reads as max_reads,
	ps.min_elapsed_time / 1000 as min_execution_time_ms,
	ps.max_elapsed_time / 1000 as max_execution_time_ms
FROM sys.dm_exec_procedure_stats ps
WHERE object_name(ps.object_id) NOT LIKE N'sp_%'
AND ps.database_id = DB_ID() -- current DB only
ORDER BY avg_exec_per_hour DESC
OPTION (RECOMPILE, MAXDOP 1);