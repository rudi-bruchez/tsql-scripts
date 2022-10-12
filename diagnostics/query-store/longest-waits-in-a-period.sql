-----------------------------------------------------------------
-- Longest waiting queries in an interval of time
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

DECLARE @when DATETIMEOFFSET(0) = '2022-10-04 10:00';

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(qsq.object_id, DB_ID())), '.', 
	    QUOTENAME(OBJECT_NAME(qsq.object_id))) as [proc],
	CAST(qsp.query_plan as xml) as query_plan,
	qsws.*
FROM sys.query_store_query qsq
JOIN sys.query_store_plan qsp ON qsq.query_id = qsp.query_id
JOIN sys.query_store_wait_stats qsws ON qsp.plan_id = qsws.plan_id
JOIN sys.query_store_runtime_stats_interval qsrsi ON 
	qsws.runtime_stats_interval_id = qsrsi.runtime_stats_interval_id
WHERE qsq.is_internal_query = 0 
AND @when BETWEEN qsrsi.start_time AND qsrsi.end_time
ORDER BY qsws.total_query_wait_time_ms DESC
OPTION (RECOMPILE, MAXDOP 1);