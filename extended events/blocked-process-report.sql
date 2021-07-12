CREATE EVENT SESSION [blocked_processes] ON SERVER 
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
ADD TARGET package0.event_file(SET filename=N'blocked_processes',max_file_size=(50))
WITH (STARTUP_STATE=OFF)
GO

-- start the session
ALTER EVENT SESSION [blocked_processes] ON SERVER STATE=START;
-- stop the sesison
ALTER EVENT SESSION [blocked_processes] ON SERVER STATE=STOP;
