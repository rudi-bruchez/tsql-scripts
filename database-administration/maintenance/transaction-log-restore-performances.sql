-----------------------------------------------------------------
-- Transaction Log Restore Performances
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @database_name sysname = '%';

SELECT 
	CONVERT(decimal(10, 2), bs.backup_size/1024./1024.) as backup_size_mb,
	CAST(bs.backup_finish_date as datetime2(0)) as backup_time,
	restore_date,
	DATEDIFF(second, LAG(restore_date) OVER (ORDER BY restore_date), restore_date) as [duration_sec],
	DATEDIFF(minute, LAG(restore_date) OVER (ORDER BY restore_date), restore_date) as [duration_minute]
FROM msdb.dbo.restorehistory rh
JOIN msdb.dbo.backupset bs ON rh.backup_set_id = bs.backup_set_id
WHERE rh.destination_database_name LIKE @database_name
ORDER BY rh.restore_date DESC