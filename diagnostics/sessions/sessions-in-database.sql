DECLARE @database_name sysname = 'mydb';

SELECT DB_NAME(database_id) as db, host_name, program_name, login_name, session_id
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID(@database_name)
AND is_user_process = 1