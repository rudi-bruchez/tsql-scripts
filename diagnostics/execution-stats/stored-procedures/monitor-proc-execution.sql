-----------------------------------------------------------------
-- Monitor stored procedure execution in SQL Server
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @proc TABLE (
	ordre tinyint identity(1,1)  primary key,
	procName sysname not null);

-- add the procedure names here	
INSERT INTO @proc (procName)
VALUES
	('PROC_1'),
	('PROC_2')

-- or search in the text
INSERT INTO @proc (procName)
SELECT OBJECT_NAME(object_id)
FROM sys.sql_modules
WHERE definition LIKE '%%'

SELECT 
	p.name AS [SP Name], 
	ps.total_elapsed_time/ps.execution_count/1000 AS avg_elapsed_time_ms,
	ps.last_elapsed_time / 1000 as last_elapsed_time_ms, 
	ps.execution_count as [exec], 
	ISNULL(ps.execution_count/DATEDIFF(Minute, ps.cached_time, GETDATE()), 0) AS [Calls/Minute],
	ps.last_execution_time as [last_exec], 
	ps.total_worker_time/ps.execution_count/1000 AS avg_worker_time_ms, 
	ps.last_worker_time/1000 AS last_worker_time_ms,
	ps.last_logical_reads, 
	ps.last_logical_writes,
	ps.cached_time,
	ps.plan_handle, -- FOR DBCC FREEPROCCACHE ()
	qp.query_plan,
	sm.uses_ansi_nulls,
	sm.uses_quoted_identifier
FROM sys.procedures AS p
JOIN @proc pr ON p.name = pr.procName
JOIN sys.dm_exec_procedure_stats AS ps ON p.[object_id] = ps.[object_id]
JOIN sys.sql_modules AS sm ON p.[object_id] = sm.[object_id]
CROSS APPLY sys.dm_exec_query_plan(ps.plan_handle) AS qp
WHERE ps.database_id = DB_ID()
AND p.is_ms_shipped = 0
ORDER BY pr.ordre
OPTION (RECOMPILE, MAXDOP 1);