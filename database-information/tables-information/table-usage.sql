-----------------------------------------------------------------
-- Operational stats on tables
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	ios.object_id, 
	object_name(ios.object_id) AS [object_name], 
	leaf_insert_count AS insert_count, 
	leaf_update_count AS update_count, 
	leaf_delete_count AS delete_count, 
	range_scan_count AS select_count
FROM  sys.dm_db_index_operational_stats (DB_ID(), NULL, NULL, NULL) ios
JOIN  sys.objects o on ios.object_id = o.object_id
where ios.index_id in (0, 1)
and o.type = 'U' and o.is_ms_shipped = 0
ORDER BY select_count DESC
OPTION (RECOMPILE, MAXDOP 1);