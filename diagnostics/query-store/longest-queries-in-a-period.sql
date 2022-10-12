-----------------------------------------------------------------
-- 
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

DECLARE @when DATETIMEOFFSET(0) = '2022-10-04 10:00';

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(qsq.object_id, DB_ID())), '.', 
	    QUOTENAME(OBJECT_NAME(qsq.object_id))) as [proc],
	qsrs.max_duration / 1000 as max_duration_ms,
	qsrs.max_cpu_time / 1000 as max_cpu_ms,
	qsrs.*
FROM sys.query_store_query qsq
JOIN sys.query_store_plan qsp ON qsq.query_id = qsp.query_id
JOIN sys.query_store_runtime_stats qsrs ON qsp.plan_id = qsrs.plan_id
JOIN sys.query_store_runtime_stats_interval qsrsi ON 
	qsrs.runtime_stats_interval_id = qsrsi.runtime_stats_interval_id
JOIN sys.sql_modules m ON qsq.object_id = m.object_id
WHERE qsq.is_internal_query = 0
AND @when BETWEEN qsrsi.start_time AND qsrsi.end_time
ORDER BY qsrs.max_duration DESC;
