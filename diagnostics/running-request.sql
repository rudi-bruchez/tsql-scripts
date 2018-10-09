-- list running requests with query text 

SELECT r.session_id, s.login_name, s.host_name, r.start_time, r.status, r.command, t.text,
	DB_NAME(r.database_id) as db, r.wait_type, r.wait_time, r.last_wait_type,
	r.open_resultset_count, r.cpu_time, r.total_elapsed_time,
	r.reads, r.writes, r.logical_reads, r.row_count, r.granted_query_memory
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.session_id > 50
AND r.command NOT IN ('VDI_CLIENT_WORKER', 'PARALLEL REDO TASK', 'UNKNOWN TOKEN', 'PARALLEL REDO HELP TASK', 
	'BRKR TASK', 'DB STARTUP', 'TASK MANAGER', 'HADR_AR_MGR_NOTIFICATION_WORKER') -- removing AlwaysOn processes
AND t.text NOT IN ('sp_server_diagnostics');