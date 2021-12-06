--------------------------------------------------------------------
-- tracking statement level recompilation in sprocs
--
-- rudi@babaluga.com, go ahead license
--------------------------------------------------------------------

CREATE EVENT SESSION [tracking_statement_recompilations] ON SERVER 
ADD EVENT sqlserver.sql_statement_recompile(
	SET collect_object_name=(1),
		collect_statement=(1)
    ACTION(
            sqlserver.client_app_name,
            sqlserver.client_hostname,
            sqlserver.username)
    WHERE (
		[recompile_cause]<>(11)) -- not taking OPTION (RECOMPILE) into account
	) 
ADD TARGET package0.ring_buffer
-- ADD TARGET package0.event_file(SET filename=N'tracking_statement_recompilations.xel',max_file_size=(50))
GO

-- start the session
ALTER EVENT SESSION [tracking_statement_recompilations] ON SERVER STATE=START;
-- stop the sesison
ALTER EVENT SESSION [tracking_statement_recompilations] ON SERVER STATE=STOP;
