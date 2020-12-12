-- seen as DBCC command in sys.dm_exec_requests

SELECT i.name
	,i.index_id
	,i.fill_factor
	,i.has_filter
	,ps.partition_number
	,ps.index_level
	,ps.page_count as pages
	,ps.compressed_page_count as compressed_pages
	,CAST(ps.avg_page_space_used_in_percent as decimal(5,2)) as [avg_pg_used_%]
	,CASE i.type_desc
		WHEN 'CLUSTERED' THEN 'c'
		WHEN 'CLUSTERED COLUMNSTORE' THEN 'cc'
		WHEN 'NONCLUSTERED' THEN 'nc'
		ELSE i.type_desc
	END as [type]
	,CASE ps.alloc_unit_type_desc
		WHEN 'IN_ROW_DATA' THEN 'IN_ROW'
		ELSE ps.alloc_unit_type_desc
	END as [alloc]
	--,CAST(ps.avg_fragment_size_in_pages as decimal(18,2)) as avg_fragment_size_in_pages
	,CAST(ps.avg_fragmentation_in_percent as decimal(5,2)) as [avg_frag_%]
	,ps.avg_record_size_in_bytes as avg_row_byte
	,ps.forwarded_record_count as forwarded_rec
	,ps.fragment_count as fragments
	,ps.ghost_record_count
	,ps.version_ghost_record_count
	,ps.index_depth
	,ps.record_count as [rows]
	,ps.compressed_page_count as compressed_pages
	,ps.columnstore_delete_buffer_state_desc as columnstore_delete_buffer_state
	,ops.*
FROM sys.indexes i
CROSS APPLY sys.dm_db_index_physical_stats(DB_ID(), i.object_id, i.index_id, NULL, N'DETAILED') ps
CROSS APPLY sys.dm_db_index_operational_stats(DB_ID(), i.object_id, i.index_id, ps.partition_number) ops
WHERE i.object_id = OBJECT_ID('<TABLE NAME>')
AND ps.page_count > 0;
