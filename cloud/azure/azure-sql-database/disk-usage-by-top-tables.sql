SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

SELECT 
    OBJECT_NAME(p.object_id) AS [table], 
    SUM(p.Rows) AS [Rows], 
    p.data_compression_desc AS [Compression],
    MIN(au.type_desc) as allocation_type,
    SUM(au.used_pages) as used_pages, -- data_pages is 0 for LOB and row-overflow units
    SUM(au.used_pages) * 8 / 1024.0 as [size MB]
FROM sys.partitions p
JOIN sys.allocation_units au ON au.container_id = CASE au.type
	WHEN 1 THEN p.hobt_id
	WHEN 2 THEN p.partition_id
	WHEN 3 THEN p.hobt_id
	END
WHERE p.index_id < 2
GROUP BY p.object_id, p.data_compression_desc, au.type
HAVING SUM(au.used_pages) > 0
ORDER BY SUM(Rows) DESC
OPTION (RECOMPILE, MAXDOP 1);