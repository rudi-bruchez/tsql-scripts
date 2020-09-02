SELECT
	backup_start_date,
	backup_finish_date,
	CASE type
		WHEN 'D' THEN 'Full'
		WHEN 'I' THEN 'Diff'
		WHEN 'L' THEN 'Log'
		WHEN 'F' THEN 'File/FG'
		WHEN 'G' THEN 'File Diff'
		WHEN 'P' THEN 'Partial'
		WHEN 'Q' THEN 'Partial Diff'
		ELSE [Type]
	END as [Type],
	DATEDIFF(minute, backup_start_date, backup_finish_date) as duration_in_minutes,
	CAST(ROUND(backup_size / 1024 / 1024 / 1024.00, 2) as numeric(10, 2)) as backup_size_GB,
	CAST(ROUND(compressed_backup_size / 1024 / 1024 / 1024.00, 2) as numeric(10, 2)) as compressed_backup_size_GB
FROM msdb.[dbo].[backupset]
WHERE Database_name = DB_NAME()
ORDER BY backup_start_date;