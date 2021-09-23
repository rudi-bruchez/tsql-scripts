--------------------------------------------------------------------
-- long running queries, by default > 5 seconds
-- with post execution plans using lightweight profiling
--
-- rudi@babaluga.com, go ahead license
--------------------------------------------------------------------

-- 5000000 = microseconds => 5 seconds
CREATE EVENT SESSION [long_queries] ON DATABASE 
ADD EVENT sqlserver.query_post_execution_plan_profile(
    ACTION(sqlserver.sql_text)
    WHERE ([duration]>(5000000))),
ADD EVENT sqlserver.rpc_completed(
    ACTION(sqlserver.sql_text)
    WHERE ([duration]>(5000000))),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(sqlserver.sql_text)
    WHERE ([duration]>(5000000)))
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
	MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,
	MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

-- start the session
ALTER EVENT SESSION [long_queries] ON DATABASE
STATE = START;
GO

-- stop the session
ALTER EVENT SESSION [long_queries] ON DATABASE
STATE = STOP;
GO