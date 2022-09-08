-----------------------------------------------------------------
-- Identifies queries running for more than 30 seconds
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	r.session_id,
	r.command,
	t.text,
	r.status,
	DB_NAME(r.database_id) as [db],
	r.wait_time,
	r.wait_type,
	r.last_wait_type,
	r.open_transaction_count as trancount,
	r.open_resultset_count,
	r.percent_complete,
	r.nest_level,
	r.total_elapsed_time as elapsed_ms,
	r.cpu_time,
	r.granted_query_memory as [mem_grant],
	r.dop,
	r.parallel_worker_count,
	s.host_name,
	s.program_name,
	s.login_name
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE s.is_user_process = 1
AND r.total_elapsed_time > 30000 -- milliseconds
AND COALESCE(r.last_wait_type, '') NOT IN ('SP_SERVER_DIAGNOSTICS_SLEEP' /* sp_server_diagnostics */)
AND r.session_id <> @@SPID -- who knows ?
OPTION (RECOMPILE, MAXDOP 1);
