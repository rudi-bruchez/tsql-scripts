-----------------------------------------------------------------
-- Analyze the IO wait stats from the Query Store
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE <database>

SELECT 
	--si.start_time, 
    si.end_time as [time],
    CASE ws.wait_category_desc
		WHEN 'Buffer IO' THEN 'Data Read'
		WHEN 'Tran Log IO' THEN 'Translog Write'
	END as IO_Type,
	CAST(AVG(ws.avg_query_wait_time_ms) as DECIMAL(10, 2)) as avg_query_wait_time_ms,
	--MIN(ws.min_query_wait_time_ms) as min_query_wait_time_ms,
	MAX(ws.max_query_wait_time_ms) as max_query_wait_time_ms,
	CAST(STDEV(ws.stdev_query_wait_time_ms) as DECIMAL(10, 2)) as stdev_query_wait_time_ms
FROM sys.query_store_wait_stats ws
JOIN sys.query_store_runtime_stats_interval si ON ws.runtime_stats_interval_id = si.runtime_stats_interval_id
WHERE ws.wait_category IN (6, 14)
GROUP BY si.end_time, ws.wait_category_desc
OPTION (RECOMPILE, MAXDOP 1);