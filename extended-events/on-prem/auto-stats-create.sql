--------------------------------------------------------------------
-- create auto stats event session
--
-- rudi@babaluga.com, go ahead license
--------------------------------------------------------------------

CREATE EVENT SESSION [auto_stats] ON SERVER 
ADD EVENT sqlserver.auto_stats(
	SET collect_database_name=(1)
    ACTION(
		sqlserver.client_app_name,
		sqlserver.client_hostname,
		sqlserver.database_name,
		sqlserver.sql_text,
		sqlserver.username)
    WHERE (
		[status]<>'Loading stats without updating')
		AND [database_id]<>(2) -- tempdb. Not interested in temporary tables
	)
ADD TARGET package0.event_file(SET filename=N'auto_stats',max_file_size=(50))
WITH (STARTUP_STATE=OFF)
GO

-- start the session
ALTER EVENT SESSION [auto_stats] ON SERVER STATE=START;
-- stop the session
/*
ALTER EVENT SESSION [auto_stats] ON SERVER STATE=STOP;
*/
