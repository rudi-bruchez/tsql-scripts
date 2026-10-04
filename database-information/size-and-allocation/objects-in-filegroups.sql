SELECT DISTINCT OBJECT_NAME(i.[object_id]) AS [ObjectName]
    ,i.[index_id] AS [IndexID]
    ,i.[name] AS [IndexName]
    ,i.[type_desc] AS [IndexType]
    ,i.[data_space_id] AS [DatabaseSpaceID]
    ,f.[name] AS [FileGroup] 
    ,d.[physical_name] AS [DatabaseFileName]
FROM [sys].[indexes] i
-- an index on a partition scheme is spread over the filegroups of the scheme
LEFT JOIN [sys].[destination_data_spaces] dds ON dds.[partition_scheme_id] = i.[data_space_id]
JOIN [sys].[filegroups] f ON f.[data_space_id] = COALESCE(dds.[data_space_id], i.[data_space_id])
JOIN [sys].[database_files] d ON f.[data_space_id] = d.[data_space_id]
ORDER BY OBJECT_NAME(i.[object_id]) ,f.[name] ,i.[data_space_id];