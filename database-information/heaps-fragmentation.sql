-----------------------------------------------------------------
-- Analyze heaps fragmentation
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--DECLARE @mode NVARCHAR(20) = N'SAMPLED'
DECLARE @mode NVARCHAR(20) = N'DETAILED'

SELECT o.object_id, o.name, create_date, modify_date, p.partition_number, p.rows, p.data_compression_desc as [compression], 
	ips.alloc_unit_type_desc as [alloc],
	ips.avg_fragmentation_in_percent as [frag %],
	ips.page_count,
	ips.avg_page_space_used_in_percent as [space used %],
	ips.ghost_record_count as [ghosts],
	ips.version_ghost_record_count as [version ghosts],
	ips.forwarded_record_count as forwarded_records
FROM sys.indexes i
JOIN sys.objects o ON i.object_id = o.object_id
JOIN sys.partitions p ON p.object_id = o.object_id AND p.index_id = i.index_id
OUTER APPLY sys.dm_db_index_physical_stats(DB_ID(), o.object_id, i.index_id, p.partition_number, @mode) ips
WHERE i.index_id = 0
AND o.type = N'U'
AND o.is_ms_shipped = 0
ORDER BY rows DESC
OPTION (RECOMPILE, MAXDOP 1);