-----------------------------------------------------------------
-- 
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT der.percent_complete
FROM sys.dm_exec_requests der
WHERE der.command LIKE '%BACKUP%'
OPTION (RECOMPILE, MAXDOP 1);