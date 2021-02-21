-----------------------------------------------------------------
-- row version details by transaction
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
SELECT 
  CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(p.object_id)), '.', QUOTENAME(OBJECT_NAME(p.object_id))) as obj,
  vs.aggregated_record_length_in_bytes / 1024 AS size_kb
FROM sys.dm_tran_top_version_generators AS vs
JOIN sys.partitions AS p ON vs.rowset_id = p.hobt_id
WHERE vs.database_id = DB_ID()
AND p.index_id IN (0,1)
ORDER BY size_kb DESC;