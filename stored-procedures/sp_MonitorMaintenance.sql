-------------------------------------------------------------------
-- Monitor running maintenance operations and transaction log usage
--
-- rudi@babaluga.com, go ahead license
-------------------------------------------------------------------

USE Master
GO

CREATE OR ALTER PROCEDURE sp_MonitorMaintenance
AS BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	;WITH [log] AS (
		SELECT
			pvt.instance_name as [db],
			[Log File(s) Size (KB)] / 1024 as log_size_MB,
			[Log File(s) Used Size (KB)] / 1024 as log_used_MB,
			[Percent Log Used] as [% log used],
			CONCAT(NULLIF(d.log_reuse_wait_desc, N'NOTHING') + ' / ',  d.recovery_model_desc) as [log]
		FROM (
			SELECT
				pc.counter_name,
				RTRIM(pc.instance_name) as instance_name,
				pc.cntr_value
			FROM sys.dm_os_performance_counters pc
			WHERE object_name LIKE N'%:Databases%'
			AND pc.counter_name IN (
				N'Log File(s) Size (KB)'
				,N'Log File(s) Used Size (KB)'
				,N'Percent Log Used'
			)
			AND pc.instance_name NOT IN
			(
				N'_Total'
				,N'master'
				,N'model'
				,N'mssqlsystemresource                                                                                                             '
			)
			) t
		PIVOT (MIN(t.cntr_value)
		FOR t.counter_name IN ([Log File(s) Size (KB)], [Log File(s) Used Size (KB)], [Percent Log Used])
		) AS pvt
		JOIN sys.databases d ON d.name = pvt.instance_name
	)

	SELECT r.session_id
		,r.status
		,r.wait_type
		,r.wait_time
		,CAST(r.percent_complete AS DECIMAL(5,2)) AS [%]
		--,r.start_time
		,r.command
		,r.blocking_session_id AS [blocker]
		,r.last_wait_type
		,CAST(r.estimated_completion_time / 1000.0 / 60 AS DECIMAL(10,2)) AS eta_min
		--,r.row_count
		,r.dop
		,r.is_resumable AS [resumable]
		,s.host_name
		,s.program_name
		,s.login_name
		,DB_NAME(r.database_id) AS [db]
		,l.log_size_MB
		,l.log_used_MB
		,l.[% log used]
		,l.[log]
		,t.text
	FROM sys.dm_exec_requests r
	JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
	JOIN [log] l ON DB_NAME(r.database_id) = l.db
	OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t
	WHERE s.is_user_process = 1
	AND (r.wait_type NOT IN (
			N'SP_SERVER_DIAGNOSTICS_SLEEP', N'XE_LIVE_TARGET_TVF', N'WAITFOR',
			N'BROKER_RECEIVE_WAITFOR')
		OR r.wait_type  IS NULL)
	AND r.session_id <> @@spid
	ORDER BY CASE 
		WHEN ( 
			r.command LIKE N'%DBCC%' OR
			r.command LIKE N'%BACKUP%' OR
			r.command LIKE N'%RESTORE%' OR
			r.command LIKE N'%CREATE%' OR
			r.command LIKE N'%ALTER%' OR
			r.command =    N'UPDATE STATISTICS'
		) THEN 1
		ELSE 2 END, 
		r.wait_time DESC
	OPTION (MAXDOP 1);

END