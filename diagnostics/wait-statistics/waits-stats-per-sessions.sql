-----------------------------------------------------------------
-- Wait Statistics per Session
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
    s.login_name, 
    DB_NAME(s.database_id) as [db], 
    s.login_time, 
    DATEDIFF(second, s.login_time, CURRENT_TIMESTAMP) as session_seconds, 
    ws.*
FROM sys.dm_exec_session_wait_stats ws
JOIN sys.dm_exec_sessions s ON ws.session_id = s.session_id
-- WHERE --wait_type = N'PREEMPTIVE_OS_QUERYREGISTRY' AND
	-- s.login_name = N'mylogin'
ORDER BY s.session_id
OPTION (RECOMPILE, MAXDOP 1);