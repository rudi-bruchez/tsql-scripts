--------------------------------------------------------------------
-- create errors (exceptions) event session
--
-- rudi@babaluga.com, go ahead license
--------------------------------------------------------------------

CREATE EVENT SESSION [errors] ON SERVER 
ADD EVENT sqlserver.error_reported(
    ACTION(
		sqlserver.client_app_name,
		sqlserver.client_hostname,
		sqlserver.database_name,
		sqlserver.query_hash,
		sqlserver.sql_text,
		sqlserver.tsql_stack,
		sqlserver.username
	)
    WHERE ([severity]>(10))
	) 
ADD TARGET package0.event_file(SET filename=N'errors.xel', max_file_size=(50))
-- ADD TARGET package0.ring_buffer
WITH (STARTUP_STATE=OFF)
GO

-- start the session
ALTER EVENT SESSION [errors] ON SERVER STATE=START;
-- stop the sesison
ALTER EVENT SESSION [errors] ON SERVER STATE=STOP;