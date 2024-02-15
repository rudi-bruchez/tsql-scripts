-----------------------------------------------------------------
-- A better sp_who like sp_who3, for a specific session
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

USE Master;
GO

CREATE OR ALTER PROCEDURE dbo.sp_WhoIsWho
	@session_id int -- compulsory
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT 
		s.login_time,
		s.host_name,
		s.program_name,
		s.client_interface_name,
		s.login_name,
		s.status,
		s.last_request_end_time,
		s.is_user_process,
		DB_NAME(s.database_id) as db,
		r.request_id,
		r.command,
		r.wait_type,
		r.wait_time,
		r.open_transaction_count,
		r.open_resultset_count,
		r.dop,
		t.text as [Query Text],
		qs.query_plan as [In Flight Plan]
FROM sys.dm_exec_sessions s
	LEFT JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
	OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t
	OUTER APPLY sys.dm_exec_query_statistics_xml(r.session_id) qs
	WHERE s.session_id = @session_id
	FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER;
END;