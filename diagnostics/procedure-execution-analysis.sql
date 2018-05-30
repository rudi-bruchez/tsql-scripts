-----------------------------------------------------------------
-- Returns information about stored procedure 
-- execution in SQL Server
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT 
	ps.cached_time, 
	ps.last_execution_time,
	ps.execution_count,
	ps.execution_count / COALESCE(NULLIF(DATEDIFF(hour, ps.cached_time, ps.last_execution_time), 0), 1) AS execution_per_hour,
	ps.total_worker_time / 1000 / 1000 AS total_worker_time_sec,
	REPLACE(REPLACE((CONVERT(varchar, CONVERT(money, ps.last_logical_reads), 1)), ',', ' '), '.00', '') AS last_logical_reads,
	qp.query_plan
FROM sys.dm_exec_procedure_stats ps
CROSS APPLY sys.dm_exec_query_plan(ps.plan_handle) qp
WHERE ps.object_id = OBJECT_ID('<PROCEDURE NAME>');