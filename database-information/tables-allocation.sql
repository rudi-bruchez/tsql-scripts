-----------------------------------------------------------------
-- See table allocations
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT OBJECT_NAME(i.[object_id]) AS [ObjectName]
    ,i.[index_id] AS [IndexID]
    ,i.[name] AS [IndexName]
    ,i.[type_desc] AS [IndexType]
    ,i.[data_space_id] AS [DatabaseSpaceID]
    ,f.[name] AS [FileGroup] 
    ,d.[physical_name] AS [DatabaseFileName]
FROM [sys].[indexes] i
JOIN [sys].[filegroups] f ON f.[data_space_id] = i.[data_space_id]
JOIN [sys].[database_files] d ON f.[data_space_id] = d.[data_space_id]
JOIN [sys].[data_spaces] s ON f.[data_space_id] = s.[data_space_id]
ORDER BY OBJECT_NAME(i.[object_id]) ,f.[name] ,i.[data_space_id]
GO