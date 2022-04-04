-----------------------------------------------------------------
-- analyze table allocations where LOB are present
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

;WITH [buffer] AS (
	SELECT 
		bd.allocation_unit_id,
		AVG(bd.free_space_in_bytes) as avg_free_space_in_pages,
		AVG(bd.row_count) as avg_row_count,
		COUNT(*) as pages_in_buffer
	FROM sys.dm_os_buffer_descriptors bd
	WHERE database_id = DB_ID()
	AND bd.page_type = 'DATA_PAGE'
	AND bd.page_level = 0
	GROUP BY bd.allocation_unit_id
)
SELECT DISTINCT
    t.NAME AS TableName,
	STUFF((
		SELECT CONCAT(', ', name) as [text()]
		FROM sys.columns c
		WHERE c.object_id = t.object_id 
		AND c.system_type_id IN (SELECT system_type_id
			FROM sys.types
			WHERE name IN (N'varchar', N'nvarchar', N'varbinary', N'text', N'ntext', N'image')
			AND c.max_length = -1
		)
		FOR XML PATH('')
	), 1, 2, '') as [columns],
    i.name as indexName,
    p.[Rows],
	a.type_desc,
    a.used_pages,
	p.data_compression_desc as [compression],
	b.avg_free_space_in_bytes,
	b.avg_row_count,
	b.pages_in_buffer
FROM sys.tables t
JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
JOIN sys.allocation_units a ON p.partition_id = a.container_id
JOIN sys.columns c ON c.object_id = t.object_id
JOIN sys.types ty ON c.system_type_id = ty.system_type_id
LEFT JOIN [buffer] b ON a.allocation_unit_id = b.allocation_unit_id
WHERE 
    t.NAME NOT LIKE 'dt%' AND
    i.OBJECT_ID > 255 AND   
    i.index_id <= 1 AND
	ty.name IN (N'varchar', N'nvarchar', N'varbinary') AND 
	c.max_length = -1
ORDER BY 
    TableName
OPTION (RECOMPILE, MAXDOP 1);
