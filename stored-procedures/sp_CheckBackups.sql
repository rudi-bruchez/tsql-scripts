USE Master;
GO

CREATE OR ALTER PROCEDURE dbo.sp_CheckBackups
AS BEGIN 
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT
		bs.database_name as [db],
		CASE sys.fn_hadr_backup_is_preferred_replica ( bs.database_name )
			WHEN 1 THEN 'here'
			ELSE 'not preferred replica'
		END as [AG],
		CAST(bs.backup_start_date as datetime2(0)) as start_date,
		CAST(bs.backup_finish_date as datetime2(0)) as finish_date,
		DATEDIFF(minute, bs.backup_start_date, bs.backup_finish_date) as duration_in_minutes,
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
		FORMAT(ROUND(bs.backup_size / 1024 / 1024.00, 2), 'n2') as backup_size_MB,
		FORMAT(ROUND(bs.compressed_backup_size / 1024 / 1024.00, 2), 'n2') as compressed_backup_size_MB,
		bmf.physical_device_name as [file],
		bs.recovery_model
	FROM msdb.[dbo].[backupset] bs
	JOIN msdb.[dbo].backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
	WHERE bs.backup_start_date > DATEADD(week, -1, CURRENT_TIMESTAMP)
	ORDER BY bs.database_name, backup_start_date DESC
	OPTION (RECOMPILE, MAXDOP 1);
END;