-----------------------------------------------------------------
-- lists indexes and tables where a fillfactor was set
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

;WITH [buffer] AS (
	SELECT b.allocation_unit_id,
		MIN(page_type) as page_type,
		AVG(row_count) as avg_rows_in_page,
		AVG(CAST(free_space_in_bytes as bigint)) as avg_free_space
	FROM sys.dm_os_buffer_descriptors b 
	WHERE b.database_id = DB_ID()
	AND b.page_level = 0
	AND b.page_type NOT IN (N'IAM_PAGE', N'BULK_OPERATION_PAGE')
	GROUP BY b.allocation_unit_id
)
SELECT 
	CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(i.object_id)), '.', 
		QUOTENAME(OBJECT_NAME(i.object_id))) as tbl,
	i.name as idx,
	i.type_desc as [type],
	i.is_primary_key as pk,
	i.is_unique as uq,
	i.fill_factor,
	p.partition_number as [partition],
	p.data_compression_desc as [compression],
	p.rows,
	REPLACE(frag.alloc_unit_type_desc, '_DATA', '') as [alloc],
	CAST(frag.avg_fragmentation_in_percent as DECIMAL(5, 2)) as [frag %],
	frag.page_count as [pages],
	REPLACE(b.page_type, '_PAGE', '') as [pages],
	b.avg_free_space,
	b.avg_rows_in_page
FROM sys.indexes i
JOIN sys.partitions p ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.system_internals_allocation_units sau ON p.partition_id = sau.container_id
OUTER APPLY sys.dm_db_index_physical_stats(DB_ID(), i.object_id, i.index_id, p.partition_number, 'LIMITED') as frag 
LEFT JOIN [buffer] b ON b.allocation_unit_id = sau.allocation_unit_id
WHERE fill_factor NOT IN (0, 100)
AND (sau.type_desc COLLATE database_default = frag.alloc_unit_type_desc COLLATE database_default  OR frag.database_id IS NULL)
ORDER BY p.rows DESC
OPTION (RECOMPILE, MAXDOP 1);
