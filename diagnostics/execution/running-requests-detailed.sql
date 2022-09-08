-----------------------------------------------------------------
-- lists running requests with query text
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

SELECT 
	r.session_id, s.login_name, s.host_name, r.start_time, r.status, r.command, 
	COALESCE(t.text, tqp.query_plan) as [text],
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
AND (r.command NOT IN (N'VDI_CLIENT_WORKER', N'PARALLEL REDO TASK', N'UNKNOWN TOKEN', N'PARALLEL REDO HELP TASK', 
	N'BRKR TASK', N'DB STARTUP', N'TASK MANAGER', N'HADR_AR_MGR_NOTIFICATION_WORKER')  OR r.command IS NULL) -- removing uninteresting processes
AND (t.text NOT IN ('sp_server_diagnostics') OR t.text IS NULL)
AND (r.wait_type NOT IN (N'BROKER_RECEIVE_WAITFOR', N'HADR_CLUSAPI_CALL', N'XE_LIVE_TARGET_TVF', N'SP_SERVER_DIAGNOSTICS_SLEEP') OR r.wait_type IS NULL)
AND r.status NOT IN ('background', 'sleeping')
AND r.session_id <> @@SPID
OPTION (RECOMPILE, MAXDOP 1);