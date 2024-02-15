-----------------------------------------------------------------
-- Top 50 consuming queries
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT TOP (50)
    p.query_id query_id,
    q.object_id object_id,
    ISNULL(OBJECT_NAME(q.object_id),'') object_name,
    qt.query_sql_text query_sql_text,
    ROUND(CONVERT(float, SUM(rs.avg_duration*rs.count_executions))/NULLIF(SUM(rs.count_executions), 0)*0.001,2) avg_duration,
    SUM(rs.count_executions) count_executions,
    COUNT(distinct p.plan_id) num_plans
FROM sys.query_store_runtime_stats rs
    JOIN sys.query_store_plan p ON p.plan_id = rs.plan_id
    JOIN sys.query_store_query q ON q.query_id = p.query_id
    JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id
WHERE rs.last_execution_time > DATEADD(day, -1, CURRENT_TIMESTAMP)
GROUP BY p.query_id, qt.query_sql_text, q.object_id
HAVING COUNT(distinct p.plan_id) >= 1
ORDER BY avg_duration DESC
OPTION (RECOMPILE, MAXDOP 1);