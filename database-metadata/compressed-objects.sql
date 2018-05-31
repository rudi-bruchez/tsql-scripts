SELECT OBJECT_NAME(i.[object_id]) AS [ObjectName]
    ,i.[index_id] AS [IndexID]
    ,i.[name] AS [IndexName]
    ,i.[type_desc] AS [IndexType]
    ,p.partition_number
	,p.data_compression_desc
FROM [sys].[indexes] i
JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
WHERE p.data_compression_desc <> 'NONE'
ORDER BY OBJECT_NAME(i.[object_id]);
