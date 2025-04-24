-----------------------------------------------------------------
-- SQL Server Query Store - Compilation Time Analysis
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	qst.query_sql_text,
	qsp.plan_id,
	qsp.plan_type_desc,
	qsp.query_id,
	CAST(qsp.avg_compile_duration / 1000 as decimal(38, 2)) as avg_compile_duration_ms,
	qsp.last_compile_duration / 1000 as last_compile_duration_ms,
	CAST(qsp.last_compile_start_time as DATETIME2(0) ) as last_compile_start_time,
	DATALENGTH(qsp.query_plan) / 1000 as plan_size_kb,
	SUM(DATALENGTH(qsp.query_plan)) OVER () / 1000 / 1000 as plan_size_total_mb
FROM sys.query_store_plan qsp
JOIN sys.query_store_query qsq ON qsp.query_id = qsq.query_id
JOIN sys.query_store_query_text qst ON qsq.query_text_id = qst.query_text_id
WHERE is_trivial_plan = 0
AND qsq.is_internal_query = 0
ORDER BY query_id
OPTION (RECOMPILE, MAXDOP 1);