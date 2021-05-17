SELECT 
    CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(v.object_id)), '.' , QUOTENAME(v.name)) as [View],
    si.Name as [Index]
FROM sys.indexes i
JOIN sys.views v ON i.object_id = v.object_id