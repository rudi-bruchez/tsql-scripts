---------------------------------------------------------------
-- scalar function execution stats 
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


SELECT 
	CONCAT(OBJECT_SCHEMA_NAME(object_id, database_id), '.',
		OBJECT_NAME(object_id, database_id)) as Nom,
	t.text,
	qp.query_plan,
	fs.[type_desc], 
	[cached_time], 
	[last_execution_time], 
	[execution_count], 
	[total_worker_time], 
	[last_worker_time], 
	[min_worker_time], 
	[max_worker_time], 
	[total_physical_reads], 
	[last_physical_reads], 
	[min_physical_reads], 
	[max_physical_reads], 
	[total_logical_writes], 
	[last_logical_writes], 
	[min_logical_writes], 
	[max_logical_writes], 
	[total_logical_reads], 
	[last_logical_reads], 
	[min_logical_reads], 
	[max_logical_reads], 
	[total_elapsed_time], 
	[last_elapsed_time], 
	[min_elapsed_time], 
	[max_elapsed_time], 
	[total_num_physical_reads], 
	[last_num_physical_reads], 
	[min_num_physical_reads], 
	[max_num_physical_reads]
FROM sys.dm_exec_function_stats fs
CROSS APPLY sys.dm_exec_sql_text(fs.sql_handle) t
CROSS APPLY sys.dm_exec_query_plan(fs.plan_handle) qp
WHERE fs.database_id = DB_ID()
OPTION (RECOMPILE, MAXDOP 1);
