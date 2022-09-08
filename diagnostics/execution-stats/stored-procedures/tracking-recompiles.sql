-----------------------------------------------------------------
-- look at probable stored procedure recompilations
-- using common constructs triggering recompilations
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

SELECT 
    object_name(p.object_id) as procName,
    ps.cached_time,
    ps.last_execution_time,
    ps.execution_count,
    CAST(ps.last_elapsed_time / 1000.0 as decimal(18, 2)) as last_elapsed_time_ms
FROM sys.sql_modules p
LEFT JOIN sys.dm_exec_procedure_stats ps ON p.object_id = ps.object_id
    AND ps.database_id = DB_ID()
WHERE p.definition LIKE '%SET ARITHABORT%'
ORDER BY ps.last_elapsed_time DESC, procName
OPTION (RECOMPILE, MAXDOP 1);