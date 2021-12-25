-----------------------------------------------------------------
-- Replaces DBCC SQLPERF(LOGSPACE) with more info
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

;WITH backuplog AS (
      SELECT 
         database_name AS [db],
         MAX(bs.backup_finish_date) AS LastBackupTime
      FROM msdb.dbo.backupset bs
      WHERE bs.type = 'L'
      GROUP BY bs.database_name
)
SELECT 
	pvt.instance_name as [db],
	[Log File(s) Size (KB)] / 1024 as log_size_MB, 
	[Log File(s) Used Size (KB)] / 1024 as log_used_MB, 
	[Percent Log Used] as [% used],
	NULLIF(d.log_reuse_wait_desc, N'NOTHING') as log_reuse_wait,
	d.recovery_model_desc as recovery_model,
	--CAST(b.LastBackupTime as datetime2(0)) as last_translog_backup
	FORMAT(b.LastBackupTime, 'G') as last_translog_backup,
	mf.name,
	mf.physical_name,
	CASE mf.max_size
		WHEN 0 THEN 'Fixed'
		WHEN -1 THEN 'Illimited'
		WHEN 268435456 THEN '2 TB'
		ELSE CONCAT((mf.max_size * 8) / 1024, ' MB')
	END AS [max],
	CASE mf.growth
		WHEN 0 THEN 'Fixed'
		ELSE 
			CASE mf.is_percent_growth
				WHEN 1 THEN CONCAT(growth, '%')
				ELSE CONCAT((mf.growth * 8) / 1024, ' MB')
			END
	END AS [growth]
FROM (
	SELECT 
		pc.counter_name,
		pc.instance_name,
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
JOIN sys.master_files mf ON d.database_id = mf.database_id AND mf.[type] = 1 -- log
LEFT JOIN backuplog b ON pvt.instance_name = b.db
ORDER BY [db] 
OPTION (RECOMPILE, MAXDOP 1);
