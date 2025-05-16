-----------------------------------------------------------------
-- Query Store - Add Query Hints
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


-- change here the SQL to search for and the hint to add
DECLARE
    @sql_to_search NVARCHAR(100) = '',
    @hint_to_add   NVARCHAR(100) = 'OPTION (USE HINT(''ENABLE_PARALLEL_PLAN_PREFERENCE''))';


SET @sql_to_search = CONCAT('%', @sql_to_search, '%');

WITH stats AS (
    SELECT qsp.query_id,
        SUM(rs.count_executions) as count_executions,
        CAST(AVG(rs.avg_duration) / 1000 as DECIMAL(18, 2)) as avg_duration_ms,
        MIN(rs.min_duration) / 1000 as min_duration_ms,
        MAX(rs.max_duration) / 1000 as max_duration_ms
    FROM sys.query_store_plan qsp
    JOIN sys.query_store_runtime_stats rs ON qsp.plan_id = rs.plan_id
    JOIN sys.query_store_runtime_stats_interval rsi ON rs.runtime_stats_interval_id = rsi.runtime_stats_interval_id
    WHERE rsi.end_time BETWEEN DATEADD(week, -1, CURRENT_TIMESTAMP) AND CURRENT_TIMESTAMP
    GROUP BY qsp.query_id
)
SELECT
    qsq.query_id,
    qst.query_sql_text,
    COALESCE(OBJECT_NAME(qsq.object_id), N'<adhoc>') as [object],
    CAST(qsq.last_execution_time as DATETIME2(0)) as last_execution_time,
    s.count_executions,
    s.avg_duration_ms,
    s.max_duration_ms,
    s.min_duration_ms,
    CONCAT('EXEC ', QUOTENAME(DB_NAME()), '.sys.sp_query_store_set_hints @query_id=', qsq.query_id,
        ', @value= N''', @hint_to_add, ''';') as [ddl]
FROM sys.query_store_query qsq
JOIN sys.query_store_query_text qst ON qsq.query_text_id = qst.query_text_id
JOIN stats s ON s.query_id = qsq.query_id
LEFT JOIN sys.query_store_query_hints qh ON qsq.query_id = qh.query_id
WHERE qh.query_id IS NULL
AND qst.query_sql_text LIKE @sql_to_search
OPTION (RECOMPILE, MAXDOP 1);