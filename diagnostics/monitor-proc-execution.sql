-----------------------------------------------------------------
-- Monitor stored procedure execution in SQL Server
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @proc TABLE (
	ordre tinyint identity(1,1)  primary key,
	procName sysname not null);
	
INSERT INTO @proc (procName)
VALUES
	('PROC_1'),
	('PROC_2')

SELECT 
	p.name AS [SP Name], 
	qs.total_elapsed_time/qs.execution_count/1000 AS avg_elapsed_time_ms,
	qs.last_elapsed_time / 1000 as last_elapsed_time_ms, 
	qs.execution_count, 
	ISNULL(qs.execution_count/DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) AS [Calls/Minute], 
	qs.total_worker_time/qs.execution_count/1000 AS avg_worker_time_ms, 
	qs.last_worker_time/1000 AS last_worker_time_ms,
	qs.last_logical_reads, 
	qs.last_logical_writes,
	qs.cached_time,
	qs.plan_handle, -- FOR DBCC FREEPROCCACHE ()
	qp.query_plan
FROM sys.procedures AS p
JOIN @proc pr ON p.name = pr.procName
JOIN sys.dm_exec_procedure_stats AS qs ON p.[object_id] = qs.[object_id]
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE qs.database_id = DB_ID()
ORDER BY pr.ordre
OPTION (RECOMPILE);