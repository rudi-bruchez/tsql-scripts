-----------------------------------------------------------------
-- table with TEXT or IMAGE types
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT DISTINCT
    t.NAME AS TableName,
	STUFF((
		SELECT CONCAT(', ', c. name, ' (', ty.name, ')') as [text()]
		FROM sys.columns c
		JOIN sys.types ty ON c.system_type_id = ty.system_type_id
		WHERE ty.name IN (N'text', N'image', N'ntext')
		AND c.object_id = t.object_id
		FOR XML PATH('')
	), 1, 2, '') as [columns],
    i.name as indexName,
    p.[Rows],
	a.type_desc,
    --sum(a.total_pages) as TotalPages, 
    a.used_pages,
    t.text_in_row_limit
    --sum(a.data_pages) as DataPages,
    --(sum(a.total_pages) * 8) / 1024 as TotalSpaceMB, 
    --(sum(a.used_pages) * 8) / 1024 as UsedSpaceMB, 
    --(sum(a.data_pages) * 8) / 1024 as DataSpaceMB
FROM sys.tables t
JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
JOIN sys.allocation_units a ON p.partition_id = a.container_id
JOIN sys.columns c ON c.object_id = t.object_id
WHERE 
    t.NAME NOT LIKE 'dt%' AND
    i.OBJECT_ID > 255 AND   
    i.index_id <= 1 AND
	c.system_type_id IN (SELECT system_type_id
						FROM sys.types
						WHERE name IN (N'text', N'image', N'ntext'))
--GROUP BY 
--    t.NAME, i.object_id, i.index_id, i.name, p.[Rows]
ORDER BY 
    TableName
OPTION (RECOMPILE, MAXDOP 1);
