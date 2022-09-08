-----------------------------------------------------------------
-- Use dm_db_index_operational_stats to get io latches
-- statistics.

-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

SELECT
	CONCAT(OBJECT_SCHEMA_NAME(i.object_id), '.', OBJECT_NAME(i.object_id)) AS tbl
   ,i.name AS idx
   ,i.type_desc AS [type]
   ,page_io_latch_wait_count
   ,page_io_latch_wait_in_ms
   ,page_latch_wait_count
   ,page_latch_wait_in_ms
   ,CAST(page_io_latch_wait_in_ms * 1.0 / page_io_latch_wait_count AS DECIMAL(10, 2)) AS avg_page_io_latch_ms
FROM sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) os
JOIN sys.indexes i
	ON os.object_id = i.object_id
		AND os.index_id = i.index_id
WHERE os.page_io_latch_wait_count > 0
ORDER BY os.page_io_latch_wait_count DESC
OPTION (RECOMPILE, MAXDOP 1);
