-----------------------------------------------------------------
-- Get internal info for Service Broker queues
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	it.name as internal_table_name, 
	q.name as queue_name,
	CAST(q.modify_date as DATETIME2(0)) as modify_date,
	idx.name as idx,
	idx.type_desc as idx_type,
	p.rows,
	p.data_compression_desc as [compression],
	au.type_desc as alloc_type,
	au.total_pages, 
	it.object_id,
	idx.index_id
FROM sys.internal_tables it 
JOIN sys.service_queues q ON it.parent_object_id = q.object_id
JOIN sys.indexes AS idx ON it.object_id = idx.object_id --AND idx.index_id IN (0,1)  
JOIN sys.partitions AS p ON p.object_id = idx.object_id AND p.index_id = idx.index_id  
JOIN sys.allocation_units AS au  
        -- IN_ROW_DATA (type 1) and ROW_OVERFLOW_DATA (type 3) => JOIN to partition's Hobt  
        -- else LOB_DATA (type 2) => JOIN to the partition ID itself.  
		ON au.container_id =    
			CASE au.type   
				WHEN 2 THEN p.partition_id   
				ELSE p.hobt_id   
			END  
ORDER BY queue_name, idx, alloc_type
OPTION (RECOMPILE, MAXDOP 1);