-----------------------------------------------------------------
-- Use dm_exec_query_stats to get the heaviest queries 
-- in the plan cache 
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT TOP 100
	DB_NAME(st.dbid) as db,
	qs.execution_count,
	qs.total_logical_reads / qs.execution_count as average_logical_reads,
	qs.total_worker_time / qs.execution_count as average_worker_time,
	qs.last_rows,
	st.text, 
	qp.query_plan, 
	qs.creation_time, 
	qs.last_execution_time, 
	qs.total_worker_time,
	qs.last_worker_time,
	qs.min_worker_time,
	qs.max_worker_time,
	qs.total_logical_reads,
	qs.last_logical_reads,
	qs.min_logical_reads,
	qs.max_logical_reads,
	qs.total_logical_writes,
	qs.last_logical_writes,
	qs.min_logical_writes,
	qs.max_logical_writes,
	qs.total_elapsed_time,
	qs.last_elapsed_time,
	qs.min_elapsed_time,
	qs.max_elapsed_time,
	qs.total_rows,
	qs.min_rows,
	qs.max_rows
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE qs.execution_count > 1
AND st.dbid IS NOT NULL AND st.dbid <> 32767 -- resource 
ORDER BY average_logical_reads DESC;