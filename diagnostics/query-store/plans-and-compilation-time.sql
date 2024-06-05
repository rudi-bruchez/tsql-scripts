-----------------------------------------------------------------
-- Title: Query Store Plans and Compilation Time
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT TOP 100
    MAX(q.last_compile_duration / 1000) as last_compile_duration_ms, --*
    MAX(q.last_bind_duration / 1000) as last_bind_duration_ms,
    MAX(qt.query_sql_text) as [text],
    MAX(LEN(qt.query_sql_text)) as [text_length],
    q.query_hash,
    COUNT(DISTINCT q.query_id) as number_of_queries,
    SUM(p.number_of_plans) as number_of_plans,
    MAX(p.max_plan_size_kb) as max_plan_size_kb
FROM sys.query_store_query q
JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id
OUTER APPLY (
    SELECT COUNT(*) as number_of_plans,
        MAX(DATALENGTH(qp.query_plan) / 1000) as max_plan_size_kb
    FROM sys.query_store_plan qp
    WHERE qp.query_id = q.query_id
) p
WHERE q.last_compile_duration > 1000000
AND q.is_internal_query = 0
GROUP BY q.query_hash
ORDER BY last_compile_duration_ms DESC
OPTION (RECOMPILE, MAXDOP 1);