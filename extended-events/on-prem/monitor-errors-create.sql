-----------------------------------------------------------------
-- Tracks exceptions (severity > 10)
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

CREATE EVENT SESSION [errors] ON SERVER 
ADD EVENT sqlserver.error_reported(
    ACTION(
        sqlserver.client_app_name,
        sqlserver.client_hostname,
        sqlserver.database_name,
        -- sqlserver.query_hash,
        sqlserver.sql_text,
        sqlserver.tsql_stack,
        sqlserver.username)
    WHERE ([severity]>(10))) 
ADD TARGET package0.event_file(SET filename=N'errors',max_file_size=(50))
WITH (
    MAX_MEMORY=4096 KB,
    EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY=30 SECONDS,
    MAX_EVENT_SIZE=0 KB,
    MEMORY_PARTITION_MODE=NONE,
    TRACK_CAUSALITY=OFF,
    STARTUP_STATE=OFF
    )
GO

-- start the session
ALTER EVENT SESSION [errors] ON SERVER STATE=START;
-- stop the session
/*
ALTER EVENT SESSION [errors] ON SERVER STATE=STOP;
*/