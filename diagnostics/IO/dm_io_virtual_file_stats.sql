-----------------------------------------------------------------
-- Use dm_io_virtual_file_stats to get IO stall statistics per
-- database and file
-- it doesn't work on Azure SQL Database, sys.master_files is
-- not there.

-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	CAST(SYSDATETIME() as DATETIME2(0)) as [Date],
	mf.type_desc as [type],
	[io_stall_read_ms] / NULLIF([num_of_reads], 0) as [ReadLatency],
	[io_stall_write_ms] / NULLIF([num_of_writes], 0) as [WriteLatency],
	[num_of_bytes_read] / NULLIF([num_of_reads], 0) as [AvgBPerRead],
	[num_of_bytes_written] / NULLIF([num_of_writes], 0) as [AvgBPerWrite],
	LEFT([mf].[physical_name],2) [Drive],
	DB_NAME([vfs].[database_id]) [DB],
	--[vfs].[database_id],
	--[vfs].[file_id],
	[vfs].[sample_ms] / 1000 / 60 / 60 / 24 as [sample_days],
	[vfs].[num_of_reads],
	[vfs].[num_of_writes],
	[vfs].[size_on_disk_bytes]/1024/1024 as [size_on_disk_MB],
	--[mf].[physical_name],
	RIGHT([mf].[physical_name], CHARINDEX(N'\',REVERSE([mf].[physical_name]))-1) as file_name
FROM [sys].[dm_io_virtual_file_stats](NULL,NULL) AS vfs
JOIN [sys].[master_files] [mf] 
    ON [vfs].[database_id] = [mf].[database_id] 
    AND [vfs].[file_id] = [mf].[file_id]
WHERE DB_NAME([vfs].[database_id]) NOT IN (N'master', N'model')
ORDER BY [DB], [type] DESC
OPTION (RECOMPILE, MAXDOP 1);