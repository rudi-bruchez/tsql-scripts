-----------------------------------------------------------------
-- Analyze REDO waits using Extended Events
--
-- replace <database_name> placeholder.
-- You can use CTRL-SHIFT-M in SSMS to assing the value
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	db_name(database_id) as [db], 
	command, 
	session_id 
FROM sys.dm_exec_requests
WHERE command IN ('PARALLEL REDO HELP TASK', 'PARALLEL REDO TASK', 'DB STARTUP')
AND database_id = db_id('<database_name, sysname, >')
ORDER BY session_id;

-- use the session_id found for the following filter ...

CREATE EVENT SESSION [redo_waits] ON SERVER 
ADD EVENT sqlos.wait_completed(
    ACTION(
		sqlserver.client_app_name,
		sqlserver.database_name,
		sqlserver.session_id,
		sqlserver.sql_text)
    WHERE (
	       [sqlserver].[session_id] = XX
		OR [sqlserver].[session_id] = XX
		)
		AND
		(
			wait_type <> N'PARALLEL_REDO_WORKER_WAIT_WORK'
			AND wait_type <> N'REDO_SIGNAL' --  ' a thread is performing log redo is waiting to be signaled that there is more log to redo.
			AND wait_type <> N'PARALLEL_REDO_DRAIN_WORKER' --  the main // redo thread for a database needs to wait for all outstanding log record redo operations to be completed.
			AND wait_type <> N'SLEEP_TASK'
	))
ADD TARGET package0.event_file(SET filename=N'redo_waits',max_file_size=(100)),
ADD TARGET package0.histogram( -- wait_info histogram
	SET filtering_event_name = N'sqlos.wait_completed',
		source_type = 0, -- Event
		source = N'wait_type')
WITH (STARTUP_STATE=OFF)
GO

-- start session
ALTER EVENT SESSION [redo_waits] ON SERVER
STATE = START;

-- stop session
ALTER EVENT SESSION [redo_waits] ON SERVER
STATE = STOP;

-- remove the session
-- DROP EVENT SESSION [redo_waits] ON SERVER;
