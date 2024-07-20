-----------------------------------------------------------------
-- Monitor aborted queries 
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

CREATE EVENT SESSION [timeouts] ON SERVER 
ADD EVENT sqlserver.rpc_completed(SET collect_statement=(1)
    ACTION(
        sqlserver.client_app_name,
        sqlserver.client_hostname,
        sqlserver.database_name,
        sqlserver.sql_text,
        sqlserver.username)
    WHERE ([result]=(2))),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(
        sqlserver.client_app_name,
        sqlserver.client_hostname,
        sqlserver.database_name,
        sqlserver.sql_text,
        sqlserver.username)
    WHERE ([result]=(2)))
ADD TARGET package0.event_file(SET filename=N'timeouts', max_file_size=(100))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO

-- start the session
ALTER EVENT SESSION [timeouts] ON SERVER STATE=START;
-- stop the session
/*
ALTER EVENT SESSION [timeouts] ON SERVER STATE=STOP;
*/