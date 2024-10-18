-----------------------------------------------------------------
-- Create the performance extended event session
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

CREATE EVENT SESSION [performances] ON SERVER 
ADD EVENT sqlserver.rpc_completed(
    ACTION(
		sqlserver.client_app_name,
		sqlserver.client_hostname,
		sqlserver.database_name,
		sqlserver.username)
    WHERE ([sqlserver].[is_system] = 0
	AND [package0].[greater_than_equal_uint64]([duration],(10000)))
	),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(
		sqlserver.client_app_name,
		sqlserver.client_hostname,
		sqlserver.database_name,
		sqlserver.username)
    WHERE ([sqlserver].[is_system] = 0
	AND [package0].[greater_than_equal_uint64]([duration],(10000)))
	)
ADD TARGET package0.event_file(SET filename=N'performances', max_file_size=(100))
WITH (STARTUP_STATE=OFF)
GO

-- start the session
ALTER EVENT SESSION [performances] ON SERVER STATE=START;
-- stop the session
ALTER EVENT SESSION [performances] ON SERVER STATE=STOP;