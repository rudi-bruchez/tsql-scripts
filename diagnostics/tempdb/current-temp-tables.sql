-----------------------------------------------------------------
-- Lists current temporary tables en tempdb. 
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT 
	t.name,
	t.create_date,
	t.modify_date,
	a.used_pages,
	p.rows AS [Rows],
	a.type_desc
FROM tempdb.sys.tables t
JOIN tempdb.sys.partitions p ON t.object_id = p.object_id
JOIN tempdb.sys.allocation_units a ON a.container_id = p.partition_id
WHERE t.is_ms_shipped = 0
ORDER BY t.name
OPTION (RECOMPILE, MAXDOP 1);