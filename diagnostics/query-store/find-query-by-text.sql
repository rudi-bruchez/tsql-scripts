-- adapted from
-- https://dba.stackexchange.com/questions/263998/find-specific-query-in-query-store
SELECT 
    qsq.query_id,
    qsq.last_execution_time,
    qsqt.query_sql_text
FROM sys.query_store_query qsq
JOIN sys.query_store_query_text qsqt
    ON qsq.query_text_id = qsqt.query_text_id
WHERE
    qsqt.query_sql_text LIKE '%your query text%';