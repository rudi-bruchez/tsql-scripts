-----------------------------------------------------------------
-- liste opened user sessions
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

USE Master;
GO

CREATE PROCEDURE sp_sessions
AS BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT 
		login_name, 
		session_id, 
		login_time, 
		program_name, 
		client_interface_name, 
		status, 
		last_request_end_time
	FROM sys.dm_exec_sessions
	WHERE is_user_process = 1
	ORDER BY login_name, session_id
	OPTION (MAXDOP 1, RECOMPILE);
END;
GO
