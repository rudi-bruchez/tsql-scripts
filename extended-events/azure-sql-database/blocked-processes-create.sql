--------------------------------------------------------------------
-- create blocked process report event session on Azure SQL Database 
-- Blocked process threshold is set at 20, no way to change it on 
-- Azure SQL.
--
-- rudi@babaluga.com, go ahead license
--------------------------------------------------------------------

CREATE EVENT SESSION [blocked_processes] ON DATABASE 
ADD EVENT sqlserver.blocked_process_report
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,
    TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

-- start the session
ALTER EVENT SESSION [blocked_processes] ON DATABASE STATE=START;

-- stop the sesison
ALTER EVENT SESSION [blocked_processes] ON DATABASE STATE=STOP;
