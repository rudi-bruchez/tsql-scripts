-----------------------------------------------------------------
-- List all compressed objects in a database

-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

SELECT 
	CONCAT(OBJECT_SCHEMA_NAME(i.[object_id]), '.', OBJECT_NAME(i.[object_id])) AS [Table]
    ,i.[index_id] AS [IndexID]
    ,i.[name] AS [IndexName]
    ,i.[type_desc] AS [IndexType]
    ,p.partition_number AS [partition]
	,p.data_compression_desc AS [compression]
FROM [sys].[indexes] i
JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
WHERE p.data_compression_desc <> 'NONE'
AND i.object_id NOT IN (SELECT object_id FROM sys.objects WHERE is_ms_shipped = 1)
ORDER BY [Table]
OPTION (RECOMPILE, MAXDOP 1);
