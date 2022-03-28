-------------------------------------------------------------------------------------------------------------------
-- create a session to trace long running queries based on 
-- elapsed execution time.
--
-- rudi@babaluga.com, go ahead license

/*
- To set the min execution time for a query to appear in the session, change these two lines below:
	[package0].[greater_than_uint64]([duration],(1000000))

  Set the value in microseconds. Current value is 1000000, which is 1 second, or 1000 milliseconds.

- Change STARTUP_STATE=ON to STARTUP_STATE=OFF if you don't want the session to be restarded when SQL Server restarts

- The sessions will write trace files in the log directory, you can find where it is in your system by 
  using the following query:
	SELECT SERVERPROPERTY('ErrorLogFileName')

  The files will be named long_running_queries*.xel
  There will be a maximum of 5 files, sizing 200 Mb max each. If you want less space, or need more space, 
  change the number of Mb in the following line :
	max_file_size=(200)
*/
-------------------------------------------------------------------------------------------------------------------


CREATE EVENT SESSION [long_running_queries] 
ON SERVER 
ADD EVENT sqlserver.rpc_completed(
    ACTION(
		sqlserver.client_app_name,
		sqlserver.client_hostname,
		sqlserver.database_name,
		sqlserver.username)
    WHERE (
		[package0].[greater_than_uint64]([duration],(1000000)) -- = 1000 milliseconds, or 1 second.
		AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'telegraf'))), -- example of session to exclude

ADD EVENT sqlserver.sql_batch_completed(
    ACTION(
		sqlserver.client_app_name,
		sqlserver.client_hostname,
		sqlserver.database_name,
		sqlserver.username)
    WHERE (
		[package0].[greater_than_uint64]([duration],(1000000)) -- = 1000 milliseconds, or 1 second.
		AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'telegraf')))  -- example of session to exclude
ADD TARGET package0.event_file(
	SET filename=N'long_running_queries',
		max_file_size=(200) -- in megabytes
	)
WITH (
        MAX_MEMORY=4096 KB,
        EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
        MAX_DISPATCH_LATENCY=30 SECONDS,
        MAX_EVENT_SIZE=0 KB,
        MEMORY_PARTITION_MODE=NONE,
        TRACK_CAUSALITY=OFF,
        STARTUP_STATE=ON -- restart the session when SQL Server restarts
)
GO

-- start the session
ALTER EVENT SESSION [long_running_queries] ON SERVER STATE=START;
-- stop the session
/*
ALTER EVENT SESSION [long_running_queries] ON SERVER STATE=STOP;
*/