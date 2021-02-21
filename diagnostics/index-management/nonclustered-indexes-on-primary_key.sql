-----------------------------------------------------------------
-- find nonclustered indexes on primary keys in the
-- current database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT
    CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(i.OBJECT_ID)), '.', QUOTENAME(OBJECT_NAME(i.OBJECT_ID))) AS TableName,
    i.name AS IndexName,
    i.index_id AS IndexID,
    CAST((8 * SUM(a.used_pages)) / 1024.0 as decimal(18, 2)) AS IndexSize_MB
FROM sys.indexes AS i
JOIN sys.partitions AS p 
    ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id
JOIN sys.allocation_units AS a 
    ON a.container_id = p.partition_id
WHERE i.type = 2
AND i.is_primary_key = 1
GROUP BY i.OBJECT_ID,i.index_id,i.name
ORDER BY IndexSize_MB DESC, OBJECT_NAME(i.OBJECT_ID);
