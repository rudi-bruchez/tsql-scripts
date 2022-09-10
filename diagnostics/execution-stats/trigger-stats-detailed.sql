-----------------------------------------------------------------
-- Use dm_exec_trigger_stats to get execution stats on triggers
-- in the current database
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
	ts.object_id
   ,OBJECT_NAME(ts.object_id, ts.database_id) as [trigger]
   ,OBJECT_NAME(t.parent_id, ts.database_id) as [table]
   ,ts.type_desc as [Type]
   ,t.create_date
   ,ts.cached_time
   ,ts.last_execution_time
   ,ts.execution_count
   ,ts.execution_count / ISNULL(NULLIF(DATEDIFF(hour, ts.cached_time, ts.last_execution_time), 0), 1) AS executions_per_hour
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
   ,STUFF(CONCAT(
	IIF(OBJECTPROPERTY( ts.object_id, 'ExecIsUpdateTrigger') = 1, ', UPDATE', '') 
	,IIF(OBJECTPROPERTY( ts.object_id, 'ExecIsDeleteTrigger') = 1, ', DELETE', '')
	,IIF(OBJECTPROPERTY( ts.object_id, 'ExecIsInsertTrigger') = 1, ', INSERT', '')), 1, 2, '') as OnStatement
   ,CASE 
		WHEN OBJECTPROPERTY( ts.object_id, 'ExecIsAfterTrigger') = 1 THEN 'AFTER'
		WHEN OBJECTPROPERTY( ts.object_id, 'ExecIsInsteadOfTrigger') = 1 THEN 'INSTEAD OF'
		ELSE '??' END AS Moment
   ,OBJECTPROPERTY( ts.object_id, 'ExecIsTriggerDisabled') AS [is_disabled] 
FROM sys.dm_exec_trigger_stats ts
JOIN sys.triggers t ON ts.object_id = t.object_id
CROSS APPLY sys.dm_exec_query_plan(ts.plan_handle) qp
WHERE ts.database_id = DB_ID()
AND t.is_ms_shipped = 0
ORDER BY ts.execution_count DESC
OPTION (RECOMPILE, MAXDOP 1);
