-- Get SQL Server databases status
SELECT 
	name, database_id, 
	SUSER_SNAME(owner_sid) as [owner],
	CAST(create_date as date) as create_date,
	CASE compatibility_level
		WHEN 65  THEN 'SQL Server 6.5'
		WHEN 70  THEN 'SQL Server 7.0'
		WHEN 80  THEN 'SQL Server 2000'
		WHEN 90  THEN 'SQL Server 2005'
		WHEN 100 THEN 'SQL Server 2008 R2'
		WHEN 110 THEN 'SQL Server 2012'
		WHEN 120 THEN 'SQL Server 2014'
		WHEN 130 THEN 'SQL Server 2016'
		WHEN 140 THEN 'SQL Server 2017'
		ELSE CAST(compatibility_level as varchar(50))
	END AS [compatibility_level],
	user_access_desc as user_access,
	is_read_only as [read_only],
	is_auto_close_on as [auto_close],
	is_auto_shrink_on as [auto_shrink],
	state_desc as [state],
	is_in_standby,
	snapshot_isolation_state_desc as snapshot_isolation,
	is_read_committed_snapshot_on as rsci,
	recovery_model_desc as [recovery],
	page_verify_option_desc as [page_verify],
	is_auto_create_stats_on as [auto_create_stats],
	is_auto_update_stats_on as [auto_update_stats],
	is_parameterization_forced as [parameterization_forced],
	is_published,
	is_subscribed,
	is_merge_published,
	log_reuse_wait_desc as log_reuse_wait,
	is_encrypted
FROM sys.databases
WHERE database_id > 4
ORDER BY 1;