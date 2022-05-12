-----------------------------------------------------------------
-- Analyzes LOB usage on a specific table, using pages in 
-- the buffer
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

DECLARE @objectid int = OBJECT_ID('<TABLE NAME')

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	MIN(i.fill_factor) as fill_factor,
	MIN(p.rows) as rows,
	MIN(p.data_compression_desc) as [compression],
	MIN(sau.total_pages) as total_pages,
	b.page_type,
	COUNT(*) as pages_in_buffer,
	SUM(b.row_count) as total_row_count,
	AVG(b.row_count) as avg_row_count,
	SUM(b.free_space_in_bytes) as total_free_space_in_bytes,
	AVG(b.free_space_in_bytes) as avg_free_space_in_bytes
FROM sys.indexes i
JOIN sys.partitions p ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.system_internals_allocation_units sau ON p.partition_id = sau.container_id
JOIN sys.dm_os_buffer_descriptors b ON b.database_id = DB_ID()
	AND b.allocation_unit_id = sau.allocation_unit_id
WHERE i.object_id = @objectid
AND i.index_id < 2
AND b.page_level = 0
AND b.page_type NOT IN (N'IAM_PAGE', N'BULK_OPERATION_PAGE')
-- AND sau.type_desc = 'LOB_DATA'
GROUP BY b.allocation_unit_id, b.page_type
OPTION (RECOMPILE, MAXDOP 1);