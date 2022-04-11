-----------------------------------------------------------------
-- Find uncompressed objects in the database
-- and generate code to compress them all
-- If you want to only generate the compression code, 
-- choose "result as text" in SSMS, to properly generate GO 
-- instructions with carriage returns.
-- 
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

DECLARE @table_name sysname = '%';
DECLARE @compressionType varchar(10) = 'ROW';
DECLARE @online bit = 1;
DECLARE @resumable bit = 0;
DECLARE @backuplog bit = 0;
DECLARE @maxdop tinyint = 2;

;WITH cte AS (
	SELECT 
		CONCAT(OBJECT_SCHEMA_NAME(i.[object_id]), '.', OBJECT_NAME(i.[object_id])) AS [Table]
		,i.[index_id] AS [IndexID]
		,i.[name] AS [Index]
		,CASE i.[type_desc] 
			WHEN 'CLUSTERED' THEN 'CL'
			WHEN 'NONCLUSTERED' THEN 'NC'
			ELSE i.[type_desc]
		 END AS [Type]
		,i.fill_factor as ff 
		,p.partition_number AS [partition]
		,p.data_compression_desc as [compression]
		,FORMAT(P.rows, 'N0') as rows
		,P.rows as rows_nb
		,FORMAT(s.[used_page_count] * 8 / 1000, 'N0') AS MB
		,STUFF((SELECT ', ' + CONCAT(c.name, ' (', t.name, 
				IIF(t.name IN ('char', 'nchar', 'varchar', 'nvarchar', 'datetime2', 'decimal', 'numeric'), CONCAT(' ', t.max_length), '') , ')') 
					AS [text()]
				FROM sys.index_columns ic
				JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
				JOIN sys.types t ON c.system_type_id = t.system_type_id
				WHERE ic.is_included_column = 0
				AND ic.object_id = i.object_id
				AND ic.index_id = i.index_id
				ORDER BY key_ordinal
				FOR XML PATH('')
			), 1, 2, '') AS keys
		,CONCAT('ALTER ', IIF(i.[type_desc] = N'HEAP', 'TABLE ', CONCAT('INDEX ', QUOTENAME(i.[name]), ' ON ')), 
			QUOTENAME(OBJECT_SCHEMA_NAME(i.[object_id])), '.', QUOTENAME(OBJECT_NAME(i.[object_id])),
			' REBUILD WITH (', IIF(@online = 1, 'ONLINE = ON, ', ''),
			IIF(@online = 1 AND @resumable = 1, 'RESUMABLE = ON, ', ''),
			IIF(i.fill_factor NOT IN (0, 100) AND i.[index_id] = 1, 'FILLFACTOR = 100, ', ''),
			IIF(i.fill_factor NOT IN (0, 100) AND i.[index_id] > 1, 'FILLFACTOR = 95, ', ''),
			'DATA_COMPRESSION = ', @compressionType , ', MAXDOP = ', @maxdop ,')',
			IIF(@backuplog = 1, CONCAT(char(13), char(10), 'GO', char(13), char(10), 
				'BACKUP LOG ', QUOTENAME(DB_NAME()) , ' TO DISK = ''NUL'';'),''),
				char(13), char(10), 'GO', char(13), char(10)
			) AS [cmd]
	FROM [sys].[indexes] i
	JOIN sys.objects o ON i.object_id = o.object_id
	JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
	JOIN sys.dm_db_partition_stats AS s ON s.partition_id = p.partition_id 
	WHERE 1 = 1
	AND p.data_compression_desc <> 'PAGE'
	AND i.object_id NOT IN (SELECT object_id FROM sys.objects WHERE is_ms_shipped = 1)
	AND o.name LIKE @table_name
)
SELECT [Table], IndexID, [Index], [Type], ff, [partition], [compression], rows, MB, keys, cmd  -- to see the result
--SELECT cmd  -- to generate the commands (choose "result as text" in SSMS)
FROM cte
ORDER BY [rows_nb] DESC
OPTION (RECOMPILE, MAXDOP 1);