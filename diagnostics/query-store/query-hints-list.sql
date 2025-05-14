-----------------------------------------------------------------
-- list query hints enabled in Query Store
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
         qsq.query_id,
         qst.query_sql_text,
         COALESCE(OBJECT_NAME(qsq.object_id), N'<adhoc>') as [object],
         qsq.last_execution_time,
         qh.query_hint_text,
         qh.query_hint_failure_count,
         qh.last_query_hint_failure_reason_desc as [hint_failure_reason],
         qh.source_desc as [source],
         qh.comment
FROM sys.query_store_query qsq
JOIN sys.query_store_query_text qst ON qsq.query_text_id = qst.query_text_id
JOIN sys.query_store_plan qsp ON qsp.query_id = qsq.query_id
JOIN sys.query_store_query_hints qh ON qsq.query_id = qh.query_id
ORDER BY qsq.query_id
OPTION (RECOMPILE, MAXDOP 1);