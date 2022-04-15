-----------------------------------------------------------------
-- Tracks a specific stored procedure execution.
-- change the procedure name : <PROCEDURE NAME>'
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

CREATE EVENT SESSION [stored_procedure] ON SERVER 
ADD EVENT sqlserver.rpc_completed(
    ACTION(
		sqlserver.client_app_name,
		sqlserver.client_hostname,
		sqlserver.sql_text,
		sqlserver.username
	)
    WHERE ([object_name]=N'<PROCEDURE NAME>')),
ADD EVENT sqlserver.query_post_execution_plan_profile( -- lightweight profiling on recent versions of SQL Server
    WHERE ([object_name]=N'<PROCEDURE NAME>'))
	
	-- uncomment if you want to tack statements inside de stored procedure
	/*
	, ADD EVENT sqlserver.sp_statement_completed(
    	WHERE (
			[object_name]=N'<PROCEDURE NAME>'
			AND duration > 0 -- only relevant statements
		)
	)
	*/
-- ADD TARGET package0.ring_buffer
ADD TARGET package0.event_file(SET filename=N'stored_procedure')
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
ALTER EVENT SESSION [stored_procedure] ON SERVER STATE=START;
-- stop the session
/*
ALTER EVENT SESSION [stored_procedure] ON SERVER STATE=STOP;
*/
