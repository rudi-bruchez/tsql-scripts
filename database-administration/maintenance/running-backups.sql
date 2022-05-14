-----------------------------------------------------------------
-- Get running backup and percent complete
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select DB_NAME(s.database_id) as db, 
	r.command,
	CAST(r.start_time as DATETIME2(0)) as start_time,
	DATEDIFF(minute, r.start_time, CURRENT_TIMESTAMP) as running_minutes,
	r.last_wait_type,
	r.wait_type,
	r.wait_time,
	CAST(r.percent_complete as DECIMAL (5,2)) as percent_complete
from sys.dm_exec_requests r
join sys.dm_exec_sessions s ON r.session_id = s.session_id
where s.session_id > 50
and r.command IN ('BACKUP DATABASE', 'RESTORE DATABASE')
OPTION (RECOMPILE, MAXDOP 1);