-----------------------------------------------------------------
-- Stored Procedure to see physical disk usage and free space 
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

USE master;
GO

CREATE PROCEDURE dbo.sp_df
AS 
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	;WITH cte AS (
		SELECT 
			vs.volume_mount_point, 
			MAX(vs.total_bytes/1048576) as Size_in_MB, 
			MAX(vs.available_bytes/1048576) as Free_in_MB
		FROM sys.master_files AS f 
		CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) vs
		GROUP BY 
			volume_mount_point, 
			total_bytes/1048576, 
			available_bytes/1048576 
)
SELECT
	volume_mount_point,
	FORMAT(Size_in_MB, 'N0') as Size_MB,
	FORMAT(Free_in_MB, 'N0') as Free_MB,
	CAST((Free_in_MB * 1.0) / Size_in_MB * 100 as DECIMAL(5, 2)) as [Free_%]
FROM cte
ORDER BY volume_mount_point;
GO