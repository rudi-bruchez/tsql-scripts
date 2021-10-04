-----------------------------------------------------------------
-- tracking statement level recompilations
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

CREATE EVENT SESSION [recompilations] ON SERVER 
ADD EVENT sqlserver.sql_statement_recompile(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.sql_text,sqlserver.username)
    WHERE ([recompile_cause]<>(11))) -- option (recompile requested)
ADD TARGET package0.event_file(SET filename=N'recompilations.xel',max_file_size=(50))
WITH (STARTUP_STATE=OFF)
GO

-- start the session
ALTER EVENT SESSION [recompilations] ON SERVER STATE=START;
-- stop the sesison
ALTER EVENT SESSION [recompilations] ON SERVER STATE=STOP;
