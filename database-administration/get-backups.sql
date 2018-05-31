SELECT 
	backup_start_date, 
	backup_finish_date,
	DATEDIFF(minute, backup_start_date, backup_finish_date) as duration_in_minutes, 
	ROUND(backup_size / 1024 / 1024 / 1024.00, 2) as backup_size_GB, 
	ROUND(compressed_backup_size / 1024 / 1024 / 1024.00, 2) as compressed_backup_size_GB
FROM msdb.[dbo].[backupset]
WHERE Database_name = DB_NAME()
ORDER BY backup_start_date;
