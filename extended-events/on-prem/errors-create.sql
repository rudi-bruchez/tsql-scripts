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
ADD TARGET 
	package0.event_file(
		SET filename=N'errors.xel', max_file_size=(50))
WITH (STARTUP_STATE=OFF)
GO
