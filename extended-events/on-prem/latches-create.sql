-----------------------------------------------------------------
-- monitor latches
-- play with duration as you need
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

CREATE EVENT SESSION [latches] ON SERVER 
ADD EVENT sqlos.wait_completed(
	SET collect_wait_resource=(1)
    ACTION(
		sqlserver.client_app_name,
		sqlserver.database_name,
		sqlserver.sql_text,
		sqlserver.username
	)
    WHERE (
		[duration] > (2) -- milliseconds
		AND ([wait_type] = 'LATCH_EX' 
		--OR [wait_type] = 'CXPACKET'
		))
	),
	ADD EVENT sqlserver.latch_suspend_end(
	ACTION(
		sqlserver.client_app_name,
		sqlserver.database_name,
		sqlserver.sql_text,
		sqlserver.username
	)
    WHERE ([duration] > 1000) -- microseconds
	)
ADD TARGET package0.event_file(
	SET filename=N'latches',max_file_size=(100) -- 100 Mb x 5 files max.
)
WITH (
	MAX_MEMORY=4096 KB, EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS, 
	MAX_DISPATCH_LATENCY=30 SECONDS, MAX_EVENT_SIZE=0 KB, 
	MEMORY_PARTITION_MODE=NONE, TRACK_CAUSALITY=OFF, STARTUP_STATE=OFF)
GO

-- start the session
ALTER EVENT SESSION [latches] ON SERVER STATE=START;
-- stop the session
/*
ALTER EVENT SESSION [latches] ON SERVER STATE=STOP;
*/