-----------------------------------------------------------------
-- Find a query in the Query Store when you know the query_id
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @query_id BIGINT = 1028;

SELECT qst.query_sql_text
FROM sys.query_store_query qsq
JOIN sys.query_store_query_text qst ON qst.query_text_id = qsq.query_text_id
WHERE qsq.query_id = @query_id
OPTION (RECOMPILE, MAXDOP 1);