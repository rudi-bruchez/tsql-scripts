-----------------------------------------------------------------
-- See tables size
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
    CONCAT(OBJECT_SCHEMA_NAME(p.object_id), '.', 
	    OBJECT_NAME(p.object_id)) AS [table], 
    FORMAT(SUM(p.Rows), 'N0') AS [Rows], 
    p.data_compression_desc AS [Compression],
    MIN(au.type_desc) as allocation_type,
    SUM(au.data_pages) as data_pages,
    SUM(au.data_pages) * 8192 / 1024 / 1024 as [size MB]
FROM sys.partitions p
JOIN sys.allocation_units au ON au.container_id = CASE au.type
	WHEN 1 THEN p.hobt_id
	WHEN 1 THEN p.partition_id
	WHEN 3 THEN p.hobt_id
	END
WHERE p.index_id < 2
GROUP BY p.object_id, p.data_compression_desc, au.type
HAVING SUM(au.data_pages) > 0
ORDER BY SUM(Rows) DESC
OPTION (RECOMPILE, MAXDOP 1);