-----------------------------------------------------------------
-- Use dm_exec_trigger_stats to get execution stats on triggers
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

DECLARE @ForCurrentDbOnly BIT = 1; -- 0 = all databases, 1 = current database

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
	DB_NAME(ts.database_id) as [database]
   ,OBJECT_NAME(ts.object_id, ts.database_id) as [trigger]
   ,ts.type_desc
   ,ts.cached_time
   ,ts.last_execution_time
   ,ts.execution_count
   ,CAST(ts.total_worker_time / 1000.0 AS DECIMAL(20, 2)) AS total_worker_time_ms
   ,CAST(ts.last_worker_time / 1000.0 AS DECIMAL(20, 2)) AS last_worker_time_ms
   ,CAST(ts.min_worker_time / 1000.0 AS DECIMAL(20, 2)) AS min_worker_time_ms
   ,CAST(ts.max_worker_time / 1000.0 AS DECIMAL(20, 2)) AS max_worker_time_ms
   ,ts.total_logical_writes
   ,ts.last_logical_writes
   ,ts.min_logical_writes
   ,ts.max_logical_writes
   ,ts.total_logical_reads
   ,ts.last_logical_reads
   ,ts.min_logical_reads
   ,ts.max_logical_reads
   ,CAST(ts.total_elapsed_time / 1000.0 AS DECIMAL(20, 2)) AS total_elapsed_time_ms
   ,CAST(ts.last_elapsed_time / 1000.0 AS DECIMAL(20, 2)) AS last_elapsed_time_ms
   ,CAST(ts.min_elapsed_time / 1000.0 AS DECIMAL(20, 2)) AS min_elapsed_time_ms
   ,CAST(ts.max_elapsed_time / 1000.0 AS DECIMAL(20, 2)) AS max_elapsed_time_ms
   ,CAST(ts.total_elapsed_time / 1000.0 / ts.execution_count AS DECIMAL(20, 2)) AS avg_elapsed_time_ms
   ,qp.query_plan
FROM sys.dm_exec_trigger_stats ts
CROSS APPLY sys.dm_exec_query_plan(ts.plan_handle) qp
WHERE (ts.database_id = DB_ID() OR @ForCurrentDbOnly = 0)
ORDER BY [database], [trigger]
OPTION (RECOMPILE, MAXDOP 1);