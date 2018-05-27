-- list running requests with query text 

SELECT r.session_id, r.start_time, r.status, r.command, t.text,
	DB_NAME(r.database_id) as db, r.wait_type, r.wait_time, r.last_wait_type,
	r.open_resultset_count, r.cpu_time, r.total_elapsed_time,
	r.reads, r.writes, r.logical_reads, r.row_count, r.granted_query_memory
FROM sys.dm_exec_requests r
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.session_id > 50;