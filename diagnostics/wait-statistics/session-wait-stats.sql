-----------------------------------------------------------------
-- Run the following query after having called a query or a
-- stored procedure in the current session, to analyze wait
-- stats for the query. 
-- 
-- rudi@babaluga.com, go ahead license
-------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


SELECT *
FROM sys.dm_exec_session_wait_stats
WHERE session_id = @@SPID
AND wait_time_ms > 0
ORDER BY wait_time_ms DESC
OPTION (RECOMPILE, MAXDOP 1);