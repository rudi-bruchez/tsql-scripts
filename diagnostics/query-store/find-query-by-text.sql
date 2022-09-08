-----------------------------------------------------------------
-- Find queries in the Query Store that contain a specific string
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

-- adapted from
-- https://dba.stackexchange.com/questions/263998/find-specific-query-in-query-store

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


DECLARE @text_to_find NVARCHAR(2000) = N'your query text';

SELECT 
    qsq.query_id,
    qsq.last_execution_time,
    qsqt.query_sql_text
FROM sys.query_store_query qsq
JOIN sys.query_store_query_text qsqt
    ON qsq.query_text_id = qsqt.query_text_id
WHERE
    qsqt.query_sql_text LIKE CONCAT('%', TRIM(@text_to_find), '%')
OPTION (RECOMPILE, MAXDOP 1);