--------------------------------------------------
-- list backups taken for the current database
-- 
-- rudi@babaluga.com, go ahead license
--------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
	bs.database_name,
	CAST(bs.backup_start_date as datetime2(0)) as start_date,
	CAST(bs.backup_finish_date as datetime2(0)) as finish_date,
	CAST(DATEDIFF(second, bs.backup_start_date, bs.backup_finish_date) AS VARCHAR(4)) + ' ' + 'Seconds' AS Duration,
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
	FORMAT(ROUND(bs.backup_size / 1024 / 1024.00, 2), 'n2') as backup_size_MB,
	FORMAT(ROUND(bs.compressed_backup_size / 1024 / 1024.00, 2), 'n2') as compressed_backup_size_MB,
	bmf.physical_device_name as [file],
	bs.first_lsn,
	bs.last_lsn,
	bs.database_backup_lsn,
	bs.checkpoint_lsn,
	bs.recovery_model
FROM msdb.[dbo].[backupset] bs
--JOIN msdb.[dbo].backupmediaset bms ON bs.media_set_id = bms.media_set_id
JOIN msdb.[dbo].backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE bs.database_name = DB_NAME()
ORDER BY backup_start_date
OPTION (RECOMPILE, MAXDOP 1);
