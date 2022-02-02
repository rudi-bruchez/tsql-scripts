-----------------------------------------------------------------
-- Trace query memory grants
--
-- it can be useful to filter by the event fields, for instance :
-- * granted_memory_kb
-- * used_memory_kb
-- * usage_percent
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

CREATE EVENT SESSION [query_memory] ON SERVER 
ADD EVENT sqlserver.query_memory_grant_usage(
    ACTION(
		sqlserver.client_app_name,
		sqlserver.client_hostname,
		sqlserver.sql_text,
		sqlserver.username)
    --WHERE ([sqlserver].[session_id]=(52))
	)
ADD TARGET package0.event_file(
	SET filename=N'query memory',
	max_file_size=(100)
	)
WITH (
	MAX_MEMORY=4096 KB,
	EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
	MAX_DISPATCH_LATENCY=30 SECONDS,
	MAX_EVENT_SIZE=0 KB,
	MEMORY_PARTITION_MODE=NONE,
	TRACK_CAUSALITY=OFF,
	STARTUP_STATE=OFF)
GO

-- start the session
ALTER EVENT SESSION [query_memory] ON SERVER STATE=START;
-- stop the sesison
ALTER EVENT SESSION [query_memory] ON SERVER STATE=STOP;