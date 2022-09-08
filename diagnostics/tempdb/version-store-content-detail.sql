-----------------------------------------------------------------
-- row version details by objects, for the current database
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	   transaction_sequence_num
	  ,version_sequence_num
	  ,DB_NAME(tvs.database_id) AS db
	  ,tvs.rowset_id
	  ,status
	  ,min_length_in_bytes
	  ,record_length_first_part_in_bytes
	  --,record_image_first_part
	  ,record_length_second_part_in_bytes
	  --,record_image_second_part
	  ,OBJECT_NAME(pa.object_id) AS [table]
	  ,pa.index_id
	  ,pa.partition_id
FROM sys.dm_tran_version_store tvs WITH (READUNCOMMITTED)
JOIN sys.partitions pa ON tvs.rowset_id = pa.partition_id
WHERE tvs.database_id = DB_ID()
OPTION (RECOMPILE, MAXDOP 1);