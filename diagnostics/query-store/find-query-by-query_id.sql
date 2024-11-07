-----------------------------------------------------------------
-- Find a query in the Query Store when you know the query_id
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @query_id BIGINT = 1028;

SELECT
	COALESCE(dest.text, 'NULL: is the QS read-only?') as query_text
FROM sys.query_store_query qsq
OUTER APPLY sys.dm_exec_sql_text(qsq.batch_sql_handle) dest
WHERE qsq.query_id = @query_id
OPTION (RECOMPILE, MAXDOP 1);