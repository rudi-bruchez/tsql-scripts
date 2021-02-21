-----------------------------------------------------------------
-- row version details by index, for the current database
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
SELECT 
	  DB_NAME(tvs.database_id) AS db
	  ,MIN(transaction_sequence_num) AS min_trans
	  ,status
	  ,SUM(record_length_first_part_in_bytes + record_length_second_part_in_bytes) / 1024 AS record_length_kb
	  ,OBJECT_NAME(pa.object_id) AS [table]
	  ,pa.index_id,
      MIN(i.name) as index_name
FROM sys.dm_tran_version_store tvs WITH (READUNCOMMITTED)
JOIN sys.partitions pa ON tvs.rowset_id = pa.partition_id
JOIN sys.indexes i ON pa.object_id = i.object_id AND pa.index_id = i.index_id
WHERE tvs.database_id = DB_ID()
GROUP BY DB_NAME(tvs.database_id)
	  ,status
	  ,OBJECT_NAME(pa.object_id)
	  ,pa.index_id
OPTION (RECOMPILE, MAXDOP 1);