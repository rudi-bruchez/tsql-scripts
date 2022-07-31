-----------------------------------------------------------------
-- 
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

CREATE OR ALTER PROCEDURE [admin].[MonitorRebuilds]
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
		,r.is_resumable AS [resumable]
		,s.host_name
		,s.program_name
		,s.login_name
	FROM sys.dm_exec_requests r
	JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
	WHERE s.is_user_process = 1
	AND (r.wait_type NOT IN (N'SP_SERVER_DIAGNOSTICS_SLEEP', N'XE_LIVE_TARGET_TVF')
	OR r.wait_type  IS NULL)
	AND r.session_id <> @@spid
	ORDER BY CASE r.command 
	WHEN N'ALTER INDEX' THEN 1 
	WHEN N'ALTER TABLE' THEN 1 
	ELSE 2 END, r.wait_time DESC

	--SELECT *
	--FROM xtsprod.sys.index_resumable_operations iro

	--SELECT CAST(CAST(SYSDATETIME() AS DATETIME2(0)) AS SQL_VARIANT) AS [value], 'now' AS [label]
	--UNION ALL
	--SELECT DATEDIFF(MINUTE, der.start_time, CURRENT_TIMESTAMP), 'running_minutes'
	--FROM sys.dm_exec_requests der WITH (NOLOCK)
	--WHERE der.session_id = @session_id
	--UNION ALL
	/*
	SELECT cntr_value, counter_name
	FROM sys.dm_os_performance_counters
	--WHERE instance_name = N'xtsprod'
	WHERE instance_name = N'xbto'
	AND counter_name IN(N'Percent Log Used', N'Log File(s) Size (KB)')
	OPTION (RECOMPILE)
	*/

	EXEC sp_logspace 'xtsprod'

	--USE [xtsprod]
	--GO
	--DBCC SHRINKFILE (N'xtsprodnew_log' , 10000)
	--GO
END