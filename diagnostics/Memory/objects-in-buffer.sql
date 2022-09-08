-----------------------------------------------------------------
-- lists objects in buffer for the current database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	MIN(o.name) AS tbl,
	MIN(i.name) AS idx,
	b.allocation_unit_id,
	COUNT(*) as pages,
	CAST(COUNT(*) * 8.0 / 1024 AS DECIMAL(20, 2)) AS mb
FROM sys.dm_os_buffer_descriptors b 
LEFT JOIN sys.allocation_units au
		ON b.allocation_unit_id = au.allocation_unit_id
	LEFT JOIN sys.partitions p
		ON (au.type IN (1,3) AND au.container_id = p.hobt_id)
		OR (au.type = 2 AND au.container_id = p.partition_id)
	LEFT JOIN sys.indexes i
		ON p.object_id = i.object_id AND p.index_id = i.index_id
	LEFT JOIN sys.objects o
		ON i.object_id = o.object_id
WHERE b.database_id = DB_ID()
GROUP BY b.allocation_unit_id --WITH ROLLUP
ORDER BY pages DESC
OPTION (RECOMPILE, MAXDOP 1);
