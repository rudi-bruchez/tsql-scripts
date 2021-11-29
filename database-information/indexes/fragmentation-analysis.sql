-----------------------------------------------------------------
-- Index fragmentation analysis for SQL Server
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT OBJECT_NAME(ips.object_id) as [table], i.name as [index], i.index_id, 
	ips.index_type_desc as [type], ips.alloc_unit_type_desc as [alloc], 
	CAST(ips.avg_fragmentation_in_percent as numeric(5,2)) as [frag%], 
	ips.fragment_count, ips.page_count, 
	COALESCE(ips.forwarded_record_count, 0) as forwarded_records, i.is_unique,
	CONCAT('ALTER ',
		CASE ips.index_type_desc
			WHEN N'HEAP' THEN CONCAT('TABLE [', OBJECT_NAME(ips.object_id), ']') 
			ELSE CONCAT('INDEX [', i.name, '] ON [', OBJECT_NAME(ips.object_id), ']')
		END, ' REBUILD') as [rebuild]
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) ips
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.page_count > 20
ORDER BY [frag%] DESC, [table], i.index_id, alloc;