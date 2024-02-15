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
	-- TODO : error_number <> 17830
	-- Network error code 0x2746 occurred while establishing a connection; the connection has been closed. This may have been caused by client or server login timeout expiration. Time spent during login: total 0 ms, enqueued 0 ms, network writes 0 ms, network reads 0 ms, establishing SSL 0 ms, network reads during SSL 0 ms, network writes during SSL 0 ms, secure calls during SSL 0 ms, enqueued during SSL 0 ms, negotiating SSPI 0 ms, network reads during SSPI 0 ms, network writes during SSPI 0 ms, secure calls during SSPI 0 ms, enqueued during SSPI 0 ms, validating login 0 ms, including user-defined login processing 0 ms. [CLIENT: ::1]
	) 
ADD TARGET package0.event_file(SET filename=N'errors.xel', max_file_size=(50))
-- ADD TARGET package0.ring_buffer
WITH (STARTUP_STATE=OFF)
GO

-- start the session
ALTER EVENT SESSION [errors] ON SERVER STATE=START;
-- stop the session
ALTER EVENT SESSION [errors] ON SERVER STATE=STOP;
