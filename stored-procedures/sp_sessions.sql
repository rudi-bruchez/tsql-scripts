-----------------------------------------------------------------
-- lists opened user sessions
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

USE Master;
GO

CREATE OR ALTER PROCEDURE dbo.sp_sessions
	@host sysname = '',
	@db sysname = ''
AS 
/* examples

EXEC dbo.sp_sessions @host = '172.16';
EXEC dbo.sp_sessions @db = 'DWH';

*/
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SET @host = CONCAT('%', @host, '%');
	SET @db = CONCAT('%', @db, '%');

	SELECT 
		s.login_name, 
		s.session_id, 
		CAST(s.login_time as datetime2(0)) as login_time, 
		s.program_name, 
		s.host_name,
		DB_NAME(s.database_id) as [db],
		s.client_interface_name, 
		s.status, 
		CAST(s.last_request_end_time as datetime2(0)) as last_request_end_time,
		COUNT(*) OVER (PARTITION BY s.login_name) as [cn #],
		c.encrypt_option,
		c.auth_scheme,
		c.net_packet_size,
		c.client_net_address,
		ib.text as [inputbuffer]
	FROM sys.dm_exec_sessions s
	LEFT JOIN sys.dm_exec_connections c ON s.session_id = c.session_id
	OUTER APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle) AS ib
	WHERE s.is_user_process = 1
	AND s.host_name LIKE @host
	AND s.database_id IN (SELECT database_id FROM sys.databases WHERE name LIKE @db)
	ORDER BY s.login_name, s.session_id
	OPTION (MAXDOP 1);

END;
GO
