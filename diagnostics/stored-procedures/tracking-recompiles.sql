SELECT 
    object_name(p.object_id) as procName,
    ps.cached_time,
    ps.last_execution_time,
    ps.execution_count,
    ps.last_elapsed_time
FROM sys.sql_modules p
LEFT JOIN sys.dm_exec_procedure_stats ps ON p.object_id = ps.object_id
    AND ps.database_id = DB_ID()
WHERE p.definition LIKE '%SET ARITHABORT%'
ORDER BY ps.last_elapsed_time DESC,
    procName