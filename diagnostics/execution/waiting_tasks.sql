-----------------------------------------------------------------
-- retrieves the tasks in the waiting queue in SQL Server 
-- rudi@babaluga.com, go ahead license
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
	s.session_id
   ,CAST(s.login_time AS DATETIME2(0)) AS login_time
   ,s.host_name
   ,s.program_name
   ,s.login_name
   ,s.status
   ,wt.wait_type
   ,wt.wait_duration_ms
   ,wt.blocking_session_id
   ,r.command
   ,t.text
FROM sys.dm_os_waiting_tasks wt
JOIN sys.dm_exec_sessions s 	ON wt.session_id = s.session_id
    JOIN sys.dm_exec_requests r ON r.session_id = s.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE s.is_user_process = 1
AND (
    (s.session_id <> @@SPID AND s.is_user_process = 1)
    OR s.session_id IS NULL -- THREADPOOL
    )
AND s.status NOT IN (N'spleeping')
AND wt.wait_type NOT IN (
	'XE_LIVE_TARGET_TVF',
	'BROKER_TASK_STOP',
    'BROKER_EVENTHANDLER',
	'XE_DISPATCHER_WAIT',
	'HADR_WORK_QUEUE',
	'SP_SERVER_DIAGNOSTICS_SLEEP',
	'PREEMPTIVE_XE_DISPATCHER',
    'WAITFOR',
    'BROKER_TRANSMITTER',
    'BROKER_TO_FLUSH',
    'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
    'SLEEP_TASK',
    'XE_TIMER_EVENT',
    'DISPATCHER_QUEUE_SEMAPHORE'
    -- 'TRACEWRITE' -- to filter out profiler
)
ORDER BY s.session_id
OPTION (RECOMPILE, MAXDOP 1);