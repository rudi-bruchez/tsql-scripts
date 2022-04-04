-----------------------------------------------------------------
-- tracks connection pooling utilization from SQL Server
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

CREATE EVENT SESSION [login_logout_from_pool] ON SERVER 
ADD EVENT sqlserver.login(
    ACTION(sqlserver.client_app_name, sqlserver.client_hostname, sqlserver.client_pid, sqlserver.database_name, sqlserver.username)
    WHERE ([is_cached]=(1))),
ADD EVENT sqlserver.logout(
    ACTION(sqlserver.client_app_name, sqlserver.client_hostname, sqlserver.client_pid, sqlserver.database_name, sqlserver.username)
    WHERE ([is_cached]=(1)))
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

-- start the session
ALTER EVENT SESSION [login_logout_from_pool] ON SERVER STATE=START;
-- stop the session
/*
ALTER EVENT SESSION [login_logout_from_pool] ON SERVER STATE=STOP;
*/