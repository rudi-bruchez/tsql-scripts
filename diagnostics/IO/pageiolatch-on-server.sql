-----------------------------------------------------------------
-- Use dm_db_index_operational_stats to get io latches
-- statistics.

-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

SELECT
	DB_NAME(os.database_id) AS db
   ,CONCAT(OBJECT_SCHEMA_NAME(os.object_id, os.database_id), '.', OBJECT_NAME(os.object_id, os.database_id)) AS tbl
   ,os.index_id
   ,page_io_latch_wait_count
   ,page_io_latch_wait_in_ms
   ,page_latch_wait_count
   ,page_latch_wait_in_ms
   ,CAST(page_io_latch_wait_in_ms * 1.0 / page_io_latch_wait_count AS DECIMAL(10, 2)) AS avg_page_io_latch_ms
FROM sys.dm_db_index_operational_stats(NULL, NULL, NULL, NULL) os
WHERE os.page_io_latch_wait_count > 0
AND OBJECT_SCHEMA_NAME(os.object_id, os.database_id) NOT IN (N'sys')
ORDER BY os.page_io_latch_wait_count DESC
OPTION (RECOMPILE, MAXDOP 1);