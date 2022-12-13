-----------------------------------------------------------------
-- Files and filegroups in the current database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
	f.name AS [File Name]
   ,f.physical_name AS [Physical Name]
   ,CAST((f.size / 128.0) AS DECIMAL(15, 2)) AS [Total Size in MB]
   ,CAST(f.size / 128.0 - CAST(FILEPROPERTY(f.name, 'SpaceUsed') AS INT) / 128.0 AS DECIMAL(15, 2))
	AS [Available Space In MB]
   ,f.[file_id]
   ,fg.name AS [Filegroup]
   ,fg.is_default
   ,fg.is_read_only
   ,f.type_desc AS [type]
   ,f.state_desc AS [state]
   ,fg.name AS [filegroup]
   ,fg.type_desc AS [fg_type]
   ,fg.is_default
FROM sys.database_files f
LEFT JOIN sys.filegroups fg
	ON f.data_space_id = fg.data_space_id
ORDER BY f.[file_id]
OPTION (RECOMPILE, MAXDOP 1);
