-----------------------------------------------------------------
-- SQL Server database files details
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
	f.name AS [File Name]
   ,f.physical_name AS [Physical Name]
   ,CAST((f.size / 128.0) AS DECIMAL(15, 2)) AS [Total Size in MB]
   ,CAST(f.size / 128.0 - CAST(FILEPROPERTY(f.name, 'SpaceUsed') AS INT) / 128.0 AS DECIMAL(15, 2))
	AS [Available Space In MB]
   ,f.[file_id]
   ,fg.name AS [Filegroup]
   ,f.is_percent_growth
   ,f.growth
   ,fg.is_default
   ,fg.is_read_only
   ,f.type_desc AS [type]
   ,f.state_desc AS [state]
   ,f.max_size
   ,f.growth
   ,f.is_persistent_log_buffer
   ,f.create_lsn
   ,f.drop_lsn
   ,f.read_only_lsn
   ,f.read_write_lsn
   ,f.differential_base_lsn
   ,f.differential_base_guid
   ,f.differential_base_time
   ,f.redo_start_lsn
   ,f.redo_start_fork_guid
   ,f.redo_target_lsn
   ,f.redo_target_fork_guid
   ,f.backup_lsn
   ,fg.name
   ,fg.type_desc
   ,fg.is_default
   ,fg.is_system
   ,fg.log_filegroup_id
   ,fg.is_read_only
   ,ds.type_desc AS data_space
FROM sys.database_files f
LEFT JOIN sys.filegroups fg
	ON f.data_space_id = fg.data_space_id
LEFT JOIN sys.data_spaces ds ON f.data_space_id = ds.data_space_id
ORDER BY f.[file_id]
OPTION (RECOMPILE, MAXDOP 1);
