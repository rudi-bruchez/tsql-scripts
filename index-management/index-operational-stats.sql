---------------------------------------------
-- look at index operational stats
--
-- rudi@babaluga.com, go ahead license
---------------------------------------------

DECLARE @table_name sysname = '%';

;WITH cte AS (
	SELECT 
		MIN(SCHEMA_NAME(tn.schema_id) + '.' + tn.name) as tbl,
		MIN(ix.name) AS idx,
		MIN(ix.fill_factor) as fill_factor,
		tn.object_id as object_id,
		ix.index_id,
		MIN(ix.type_desc) as idxType,
		MIN(CAST(ix.is_unique as tinyint)) as is_unique,
		MIN(CAST(ix.is_primary_key as tinyint)) as is_primary_key,
		SUM(ps.[used_page_count]) * 8 AS IndexSizeKB,
		FORMAT(SUM(ps.[used_page_count]) * 8.192 / 1024, 'N', 'fr-fr') as IndexSizeMBformatted,
		CONCAT(STUFF((SELECT ', ' + c.name as [text()]
				FROM sys.index_columns ic
				JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
				WHERE ic.object_id = tn.object_id AND ic.index_id = ix.index_id
				AND ic.is_included_column = 0
				ORDER BY ic.key_ordinal
				FOR XML PATH('')), 1, 2, ''), ' (' +
			STUFF((SELECT ', ' + c.name as [text()]
				FROM sys.index_columns ic
				JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
				WHERE ic.object_id = tn.object_id AND ic.index_id = ix.index_id
				AND ic.is_included_column = 1
				ORDER BY ic.key_ordinal
				FOR XML PATH('')), 1, 2, '') + ')') as [key],
		COUNT(p.partition_id) as partitions,
		MAX(p.data_compression_desc) as compr
	FROM sys.partitions p
	JOIN sys.dm_db_partition_stats AS ps ON p.object_id = ps.object_id
		AND p.index_id = ps.index_id AND p.partition_id = ps.partition_id
	JOIN sys.indexes AS ix ON ps.[object_id] = ix.[object_id] AND ps.[index_id] = ix.[index_id]
	JOIN sys.tables tn ON tn.object_id = ix.object_id
	WHERE 
		tn.[name] LIKE @table_name AND 
		ix.index_id > 1 -- do not take clustered index into consideration
	GROUP BY tn.object_id, ix.index_id
)
SELECT 
	cte.tbl,
	cte.idx,
	CASE cte.idxType
		WHEN 'NONCLUSTERED' THEN 'NC'
		ELSE cte.idxType
	END as t,
	cte.fill_factor as ff,
	cte.IndexSizeMBformatted as MB,
	cte.[key],
	cte.index_id,
	iops.leaf_insert_count as leaf_insert,
	iops.leaf_delete_count + iops.leaf_ghost_count as leaf_delete,
	iops.leaf_update_count as leaf_update,
	iops.leaf_allocation_count as leaf_alloc,
	iops.leaf_page_merge_count,
	iops.nonleaf_insert_count as nonleaf_insert,
	iops.nonleaf_delete_count as nonleaf_delete,
	iops.nonleaf_update_count as nonleaf_update,
	iops.nonleaf_allocation_count as nonleaf_alloc,
	--iops.nonleaf_page_merge_count,
	iops.row_lock_wait_count,
	iops.row_lock_wait_in_ms,	
	iops.page_lock_wait_count,
	iops.page_io_latch_wait_count,
	iops.page_io_latch_wait_in_ms,
	iops.page_latch_wait_count,
	iops.tree_page_io_latch_wait_count,
	iops.tree_page_latch_wait_count,
	ips.page_count,
	CAST(ips.avg_fragmentation_in_percent as decimal (5, 2)) as avg_frag,
	ips.fragment_count
FROM cte
CROSS APPLY sys.dm_db_index_operational_stats(DB_ID(), cte.object_id, cte.index_id, NULL) iops
CROSS APPLY sys.dm_db_index_physical_stats(DB_ID(), cte.object_id, cte.index_id, NULL, 'LIMITED') ips
ORDER BY cte.tbl, [key]