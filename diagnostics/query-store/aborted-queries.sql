-----------------------------------------------------------------
-- Find aborted queries in the Query Store
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	qsq.query_id, 
	qst.query_sql_text, 
	qsr.execution_type_desc, 
	qsr.last_execution_time
FROM sys.query_store_runtime_stats qsr
JOIN sys.query_store_plan qsp ON qsr.plan_id = qsp.plan_id
JOIN sys.query_store_query qsq ON qsp.query_id = qsq.query_id
JOIN sys.query_store_query_text qst ON qst.query_text_id = qsq.query_text_id
WHERE qsr.execution_type_desc IN (N'Aborted', N'Exception') 
AND qsr.last_execution_time > DATEADD(hour, -2, CURRENT_TIMESTAMP)
OPTION (RECOMPILE, MAXDOP 1);
