-----------------------------------------------------------------
-- running BULK INSERT (bcp) operations
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	r.command,
	CAST(r.start_time as datetime2(0)) as start_time,
	DATEDIFF(second, r.start_time, CURRENT_TIMESTAMP) as elapsed_seconds,
	DATEDIFF(minute, r.start_time, CURRENT_TIMESTAMP) as elapsed_minutes,
	r.status,
	r.last_wait_type,
	t.text,
	db.name as db,
	db.recovery_model_desc as [recovery],
	(
		SELECT cntr_value / 1024
		FROM sys.dm_os_performance_counters c
		WHERE TRIM(c.object_name) LIKE '%:Databases'
		AND TRIM(c.counter_name) = N'Log File(s) Size (KB)'
		AND TRIM(c.instance_name) = db.name
	) as log_mb,
	(
		SELECT cntr_value
		FROM sys.dm_os_performance_counters c
		WHERE TRIM(c.object_name) LIKE '%:Databases'
		AND TRIM(c.counter_name) = N'Percent Log Used'
		AND TRIM(c.instance_name) = db.name
	) as [% log]
FROM sys.dm_exec_requests r
JOIN sys.databases db ON r.database_id = db.database_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE 
    r.command = N'BULK INSERT'
ORDER BY r.start_time
OPTION (RECOMPILE, MAXDOP 1);
