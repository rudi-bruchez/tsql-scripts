-----------------------------------------------------------------
-- lists running requests with query text, full details
-- for SQL Server 2008
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	CAST(SYSDATETIME() as DATETIME2(3)) as [now]],
	r.session_id as [session],
	CAST(r.start_time AS DATETIME2(0)) AS [start],
	r.status,
	r.command,
	t.text,
	--r.statement_end_offset, r.statement_start_offset,
	LTRIM(CASE 
		WHEN r.statement_start_offset > 0 AND r.statement_end_offset > 0 THEN 
			SUBSTRING(t.text, 
				r.statement_start_offset / 2, 
				(r.statement_end_offset - r.statement_start_offset) / 2) 
		ELSE t.text END) as text_offset,
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
	CAST(r.percent_complete AS DECIMAL(5, 2)) AS [%], 
	qp.query_plan,
	CAST(tqp.query_plan as XML) as specific_plan,
	mg.dop,
	mg.requested_memory_kb,
	mg.granted_memory_kb,
	mg.max_used_memory_kb,
	mg.is_small
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
OUTER APPLY sys.dm_exec_sql_text (r.plan_handle) t
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) qp
OUTER APPLY sys.dm_exec_text_query_plan(plan_handle, r.statement_start_offset, r.statement_end_offset) tqp
LEFT JOIN sys.dm_exec_query_memory_grants mg ON mg.session_id = r.session_id AND mg.request_id = r.request_id
WHERE s.is_user_process = 1
AND r.command NOT IN ('VDI_CLIENT_WORKER', 'PARALLEL REDO TASK', 'UNKNOWN TOKEN', 'PARALLEL REDO HELP TASK', 
	'BRKR TASK', 'DB STARTUP', 'TASK MANAGER', 'HADR_AR_MGR_NOTIFICATION_WORKER') -- removing AlwaysOn processes
AND (t.text NOT IN ('sp_server_diagnostics') OR t.text IS NULL)
AND (r.wait_type NOT IN (N'BROKER_RECEIVE_WAITFOR', N'HADR_CLUSAPI_CALL', N'XE_LIVE_TARGET_TVF', N'SP_SERVER_DIAGNOSTICS_SLEEP') OR r.wait_type IS NULL)
AND r.session_id <> @@SPID
ORDER BY total_elapsed_time DESC
OPTION (RECOMPILE, MAXDOP 1);