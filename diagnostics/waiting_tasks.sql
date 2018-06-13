------------------------------------------------------------
-- retrieves the tasks in the waiting queue in SQL Server 
-- rudi@babaluga.com, go ahead license
------------------------------------------------------------
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
FROM sys.dm_os_waiting_tasks wt
JOIN sys.dm_exec_sessions s
	ON wt.session_id = s.session_id
WHERE s.session_id > 50
AND s.session_id <> @@SPID
AND wt.wait_type NOT IN (
	'XE_LIVE_TARGET_TVF',
	'BROKER_TASK_STOP',
	'XE_DISPATCHER_WAIT',
	'HADR_WORK_QUEUE',
	'SP_SERVER_DIAGNOSTICS_SLEEP',
	'PREEMPTIVE_XE_DISPATCHER',
    'WAITFOR'
)
ORDER BY s.session_id;