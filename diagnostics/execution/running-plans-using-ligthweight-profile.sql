-----------------------------------------------------------------
-- Use dm_exec_query_statistics_xml to get the currently 
-- executing plan using lightweight profiling. 
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

/*
    to enable globally lightweight profiling in v2 versions 
    (Lightweight query execution statistics profiling infrastructure v2)
    SQL Server 2016 (13.x) SP1 through SQL Server 2017 (14.x))
    Since SQL Server 2019 (infrastructure v3), it is enabled by default
    https://docs.microsoft.com/en-us/sql/relational-databases/performance/query-profiling-infrastructure
*/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

DBCC TRACEON (7412, -1)

SELECT r.session_id, s.login_name, s.host_name, r.start_time, r.status, r.command, t.text,
	DB_NAME(r.database_id) as db, r.wait_type, r.wait_time, r.last_wait_type,
	r.open_resultset_count, r.cpu_time, r.total_elapsed_time,
	r.reads, r.writes, r.logical_reads, r.row_count, r.granted_query_memory, r.blocking_session_id,
	p.query_plan, qx.query_plan as executing_plan
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) p
OUTER APPLY sys.dm_exec_query_statistics_xml(s.session_id) qx
WHERE s.is_user_process = 1
AND r.command NOT IN ('VDI_CLIENT_WORKER', 'PARALLEL REDO TASK', 'UNKNOWN TOKEN', 'PARALLEL REDO HELP TASK', 
	'BRKR TASK', 'DB STARTUP', 'TASK MANAGER', 'HADR_AR_MGR_NOTIFICATION_WORKER') -- removing uninteresting processes
AND t.text NOT IN ('sp_server_diagnostics')
AND r.wait_type NOT IN ('BROKER_RECEIVE_WAITFOR')
AND r.session_id <> @@SPID
OPTION (RECOMPILE, MAXDOP 1);

