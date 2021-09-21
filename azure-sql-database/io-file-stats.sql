-----------------------------------------------------------------
-- Use dm_io_virtual_file_stats to get IO stall statistics per
-- file

-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
	CAST(SYSDATETIME() AS DATETIME2(0)) AS [Date]
   ,df.type_desc AS [type]
   ,[io_stall_read_ms] / NULLIF([num_of_reads], 0) AS [ReadLatency]
   ,[io_stall_write_ms] / NULLIF([num_of_writes], 0) AS [WriteLatency]
   ,[num_of_bytes_read] / NULLIF([num_of_reads], 0) AS [AvgBPerRead]
   ,[num_of_bytes_written] / NULLIF([num_of_writes], 0) AS [AvgBPerWrite]
   ,DB_NAME([vfs].[database_id]) [DB]
   ,[vfs].[sample_ms] / 1000 / 60 / 60 / 24 AS [sample_days]
   ,[vfs].[num_of_reads]
   ,[vfs].[num_of_writes]
   ,[vfs].[size_on_disk_bytes] / 1024 / 1024 AS [size_on_disk_MB]
   ,[df].[physical_name] AS file_name
FROM [sys].[dm_io_virtual_file_stats](NULL, NULL) AS vfs
JOIN sys.database_files AS df
	ON vfs.[file_id] = df.[file_id]
WHERE DB_NAME([vfs].[database_id]) NOT IN (N'master', N'model')
ORDER BY [DB], [type] DESC
OPTION (RECOMPILE, MAXDOP 1);