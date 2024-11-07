-----------------------------------------------------------------
-- Tables with row that can exceed 8060 bytes
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
    CONCAT(OBJECT_SCHEMA_NAME(i.object_id), '.', OBJECT_NAME(i.object_id)) AS [Table],
    i.name AS [Index],
    i.type_desc AS IndexType,
    SUM(c.max_length) AS TotalRowSizeBytes
FROM sys.indexes i
JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
JOIN sys.types t ON c.system_type_id = t.system_type_id
GROUP BY 
    i.object_id, i.index_id, i.name, i.type_desc
HAVING 
    SUM(CASE 
        WHEN t.name IN ('varchar', 'nvarchar', 'varbinary') AND c.max_length = -1 THEN 0
        WHEN t.name IN ('varchar', 'nvarchar', 'varbinary', 'sql_variant') THEN c.max_length
        WHEN t.name IN ('text', 'ntext', 'image') THEN 16
        WHEN t.name IN ('xml') THEN 0
        ELSE c.max_length
    END) > 8060
ORDER BY 
    TotalRowSizeBytes DESC
OPTION (RECOMPILE, MAXDOP 1);
