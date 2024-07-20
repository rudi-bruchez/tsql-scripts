---------------------------------------------
-- index physical stats, fragmentation
-- analysis
--
-- rudi@babaluga.com, go ahead license
---------------------------------------------

DECLARE @table_name sysname = '%';

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
     t.name AS [table]
	,i.name AS [index]
	,i.index_id
	,i.fill_factor
	,ps.partition_number AS [partition]
	,ps.page_count as pages
	,ps.compressed_page_count as compressed_pages
	,CAST(ps.avg_page_space_used_in_percent as decimal(5,2)) as [avg_pg_used_%]
	,CASE i.type_desc
		WHEN 'CLUSTERED' THEN 'c'
		WHEN 'CLUSTERED COLUMNSTORE' THEN 'cc'
		WHEN 'NONCLUSTERED' THEN 'nc'
		ELSE i.type_desc
	END as [type]
	,p.data_compression_desc as [compr]
	,CASE ps.alloc_unit_type_desc
		WHEN 'IN_ROW_DATA' THEN 'IN_ROW'
		ELSE ps.alloc_unit_type_desc
	END as [alloc]
	,p.partition_number as [partition]
	--,CAST(ps.avg_fragment_size_in_pages as decimal(18,2)) as avg_fragment_size_in_pages
	,CAST(ps.avg_fragmentation_in_percent as decimal(5,2)) as [avg_frag_%]
	,ps.avg_record_size_in_bytes as avg_row_byte
	,ps.forwarded_record_count as forwarded_rec
	,ps.fragment_count as fragments
	,ps.ghost_record_count
	,ps.version_ghost_record_count
	,ps.index_depth
	,ps.record_count as [rows]
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
CROSS APPLY sys.dm_db_index_physical_stats(DB_ID(), i.object_id, i.index_id, p.partition_number, N'DETAILED') ps
WHERE t.name LIKE @table_name
AND ps.page_count > 0
AND ps.index_level  = 0
ORDER BY [table], i.index_id
OPTION (RECOMPILE, MAXDOP 1);
