CREATE EVENT SESSION [blocked process report] ON SERVER 
ADD EVENT sqlserver.blocked_process_report(
    ACTION(
            sqlserver.client_app_name,
            sqlserver.client_hostname,
            sqlserver.database_name,
            sqlserver.sql_text,
            sqlserver.tsql_stack,
            sqlserver.username
            )
        )
ADD TARGET package0.event_file(SET filename=N'blocked process report',max_file_size=(50))
WITH (STARTUP_STATE=OFF)
GO

-- start the session
ALTER EVENT SESSION [blocked process report] ON SERVER STATE=START;
-- stop the sesison
ALTER EVENT SESSION [blocked process report] ON SERVER STATE=STOP;
