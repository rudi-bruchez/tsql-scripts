--------------------------------------------------------------------
-- create recompilations event session
--
-- rudi@babaluga.com, go ahead license
--------------------------------------------------------------------

CREATE EVENT SESSION [recompilations] ON SERVER 
ADD EVENT sqlserver.sql_statement_recompile(
    SET collect_object_name=(1),collect_statement=(1)
    ACTION(
		sqlserver.client_app_name,
		sqlserver.client_hostname,
		sqlserver.database_name,
		sqlserver.sql_text,
		sqlserver.username)
    WHERE (
        [recompile_cause]<>('Option (recompile) requested')
        AND [recompile_cause]<>'Deferred compile'
    )
	)
ADD TARGET package0.event_file(SET filename=N'recompilations',max_file_size=(50))
WITH (STARTUP_STATE=OFF)
GO

-- start the session
ALTER EVENT SESSION [recompilations] ON SERVER STATE=START;
-- stop the session
/*
ALTER EVENT SESSION [recompilations] ON SERVER STATE=STOP;
*/
