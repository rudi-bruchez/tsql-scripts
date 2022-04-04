-----------------------------------------------------------------
-- Get post-execution execution plan, using lightweight profiling
-- infastructure on SQL Server 2019 and 2017 CU 14.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT OBJECT_ID('<MY PROCEDURE>');
GO

CREATE EVENT SESSION [plans_proc] ON SERVER 
ADD EVENT sqlserver.query_post_execution_plan_profile(
    ACTION(
		sqlserver.plan_handle,
		sqlserver.session_id,
		sqlserver.sql_text)
    WHERE (
		[database_name]=N'<DB NAME>' AND 
		[object_id]=1234)
		)
ADD TARGET package0.ring_buffer(SET max_memory=(25600))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

-- start the session
ALTER EVENT SESSION [plans_proc] ON SERVER STATE=START;
-- stop the session
/*
ALTER EVENT SESSION [plans_proc] ON SERVER STATE=STOP;
*/