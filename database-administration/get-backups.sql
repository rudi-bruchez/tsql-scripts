--------------------------------------------------
-- list backups taken for the current database
-- 
-- rudi@babaluga.com, go ahead license
--------------------------------------------------
SELECT
	bs.backup_start_date,
	bs.backup_finish_date,
	CASE bs.[type]
			WHEN 'D' THEN 'Full'
			WHEN 'I' THEN 'Diff'
			WHEN 'L' THEN 'Log'
			WHEN 'F' THEN 'File/FG'
			WHEN 'G' THEN 'File Diff'
			WHEN 'P' THEN 'Partial'
			WHEN 'Q' THEN 'Partial Diff'
			ELSE [type]
	END as [type],
	DATEDIFF(minute, bs.backup_start_date, bs.backup_finish_date) as duration_in_minutes,
	CAST(ROUND(bs.backup_size / 1024 / 1024 / 1024.00, 2) as numeric(10, 2)) as backup_size_GB,
	CAST(ROUND(bs.compressed_backup_size / 1024 / 1024 / 1024.00, 2) as numeric(10, 2)) as compressed_backup_size_GB,
	bmf.physical_device_name as [file]
FROM msdb.[dbo].[backupset] bs
--JOIN msdb.[dbo].backupmediaset bms ON bs.media_set_id = bms.media_set_id
JOIN msdb.[dbo].backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE bs.database_name = DB_NAME()
ORDER BY backup_start_date;