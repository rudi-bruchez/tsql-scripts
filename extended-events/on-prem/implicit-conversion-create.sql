-----------------------------------------------------------------
-- tracing implicit conversions warnings to find plans where
-- the conversion prevents a seek
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

CREATE EVENT SESSION [implicit_conversions] ON SERVER 
ADD EVENT sqlserver.plan_affecting_convert(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.sql_text)
    WHERE ([convert_issue]='Seek Plan')
)
ADD TARGET package0.event_file(SET filename=N'implicit_conversions',max_file_size=(50)),
WITH (STARTUP_STATE=OFF)
GO

-- start the session
ALTER EVENT SESSION [implicit_conversions] ON SERVER STATE=START;
-- stop the session
/*
ALTER EVENT SESSION [implicit_conversions] ON SERVER STATE=STOP;
*/
