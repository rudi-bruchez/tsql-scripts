-----------------------------------------------------------------
-- show free drive space in MB
-- available only in SQL Server 2019 onwards
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	fixed_drive_path as [path], 
	CAST(free_space_in_bytes / 1024.0 / 1024 as numeric(10, 2)) as [free_mb]
FROM sys.dm_os_enumerate_fixed_drives
OPTION (RECOMPILE, MAXDOP 1);