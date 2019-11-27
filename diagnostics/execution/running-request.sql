-- 1. list running requests with query text 

SELECT r.session_id, s.login_name, s.host_name, r.start_time, r.status, r.command, COALESCE(t.text, tqp.query_plan) as [text],
	DB_NAME(r.database_id) as db, r.wait_type, r.wait_time, r.last_wait_type,
	r.open_resultset_count, r.cpu_time, r.total_elapsed_time,
	r.reads, r.writes, r.logical_reads, r.row_count, r.granted_query_memory, r.blocking_session_id
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t
-- in case we have no t.text ... 
OUTER APPLY sys.dm_exec_text_query_plan(plan_handle, r.statement_start_offset, r.statement_end_offset) tqp
WHERE s.is_user_process = 1
-- WHERE r.session_id > 50
AND r.command NOT IN ('VDI_CLIENT_WORKER', 'PARALLEL REDO TASK', 'UNKNOWN TOKEN', 'PARALLEL REDO HELP TASK', 
	'BRKR TASK', 'DB STARTUP', 'TASK MANAGER', 'HADR_AR_MGR_NOTIFICATION_WORKER') -- removing uninteresting processes
AND (t.text NOT IN ('sp_server_diagnostics') OR t.text IS NULL)
AND (r.wait_type NOT IN ('BROKER_RECEIVE_WAITFOR', 'HADR_CLUSAPI_CALL') OR r.wait_type IS NULL)
AND r.status NOT IN ('background', 'sleeping')
AND r.session_id <> @@SPID
OPTION (RECOMPILE);

-- 2. short version
SELECT r.session_id, t.text, r.status, DB_NAME(database_id) as db, wait_type, wait_time, last_wait_type, open_transaction_count, p.query_plan
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) p
WHERE r.session_id > 50 AND r.session_id <> @@SPID
AND last_wait_type NOT IN ('SP_SERVER_DIAGNOSTICS_SLEEP')

-- 3. with full details, for SQL 2008
-- TODO : add sys.dm_exec_input_buffer for more recent versions
SELECT 
	CAST(SYSDATETIME() as DATETIME2(3)) as quand,
	r.session_id,
	r.start_time,
	r.status,
	r.command,
	t.text,
	--r.statement_end_offset, r.statement_start_offset,
	CASE 
		WHEN r.statement_start_offset > 0 AND r.statement_end_offset > 0 THEN 
			SUBSTRING(t.text, 
				r.statement_start_offset / 2, 
				(r.statement_end_offset - r.statement_start_offset) / 2) 
		ELSE t.text END as text_offset,
	OBJECT_NAME(t.objectid, r.database_id) as [proc],
	DB_NAME(r.database_id) as db,
	r.blocking_session_id,
	r.wait_type,
	r.wait_time,
	r.last_wait_type,
	r.open_transaction_count,
	r.open_resultset_count,
	r.cpu_time,
	r.total_elapsed_time,
	r.reads,
	r.logical_reads,
	r.row_count,
	r.granted_query_memory,
	r.executing_managed_code, 
	qp.query_plan,
	CAST(tqp.query_plan as XML) as specific_plan,
	mg.dop,
	mg.requested_memory_kb,
	mg.granted_memory_kb,
	mg.max_used_memory_kb,
	mg.is_small
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text (r.plan_handle) t
CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) qp
OUTER APPLY sys.dm_exec_text_query_plan(plan_handle, r.statement_start_offset, r.statement_end_offset) tqp
LEFT JOIN sys.dm_exec_query_memory_grants mg ON mg.session_id = r.session_id AND mg.request_id = r.request_id
WHERE s.is_user_process = 1
AND r.command NOT IN ('VDI_CLIENT_WORKER', 'PARALLEL REDO TASK', 'UNKNOWN TOKEN', 'PARALLEL REDO HELP TASK', 
	'BRKR TASK', 'DB STARTUP', 'TASK MANAGER', 'HADR_AR_MGR_NOTIFICATION_WORKER') -- removing AlwaysOn processes
AND t.text NOT IN ('sp_server_diagnostics')
AND r.wait_type NOT IN ('BROKER_RECEIVE_WAITFOR')
AND r.session_id <> @@SPID
ORDER BY total_elapsed_time DESC
OPTION (RECOMPILE);