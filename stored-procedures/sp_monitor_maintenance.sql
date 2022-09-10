-----------------------------------------------------------------
-- Monitor running maintenance operations
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

USE Master;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_monitor_maintenance]
AS BEGIN
    SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT r.session_id
		,r.status
		,r.wait_type
		,r.wait_time
		,CAST(r.percent_complete AS DECIMAL(5,2)) AS [%]
		--,r.start_time
		,r.command
		,DB_NAME(r.database_id) AS [db]
		,r.blocking_session_id AS [blocker]
		,r.last_wait_type
		,CAST(r.estimated_completion_time / 1000.0 / 60 AS DECIMAL(10,2)) AS eta_min
		--,r.row_count
		,r.dop
		,r.is_resumable AS [resumable]  -- comment if SQL Server version is < 140
		,s.host_name
		,s.program_name
		,s.login_name
	FROM sys.dm_exec_requests r
	JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
	WHERE s.is_user_process = 1
	AND (r.wait_type NOT IN (N'SP_SERVER_DIAGNOSTICS_SLEEP', N'XE_LIVE_TARGET_TVF')
	OR r.wait_type  IS NULL)
	AND r.session_id <> @@spid
	AND ( 
		r.command LIKE N'%DBCC%' OR
		r.command LIKE N'%BACKUP%' OR
		r.command LIKE N'%RESTORE%' OR
		r.command LIKE N'%CREATE%' OR
		r.command LIKE N'%ALTER%'
	)
	ORDER BY r.wait_time DESC
	OPTION (MAXDOP 1);

END