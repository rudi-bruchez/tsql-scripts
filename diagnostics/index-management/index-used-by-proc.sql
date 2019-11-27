---------------------------------------------------------------------------------------------------------------------------
-- find procedure using specific indexes
--
-- rudi@babaluga.com, go ahead license
-- code adapted from https://stackoverflow.com/questions/2247713/how-to-find-what-stored-procedures-are-using-what-indexes
---------------------------------------------------------------------------------------------------------------------------

;with xmlnamespaces ('http://schemas.microsoft.com/sqlserver/2004/07/showplan' as sp),
cte AS (
    SELECT 
        OBJECT_NAME(s.object_id) as ProcedureName,
        n.value(N'@Index', N'sysname') as IndexName,
        s.execution_count,
        p.query_plan
    FROM sys.dm_exec_procedure_stats as s
    CROSS APPLY sys.dm_exec_sql_text(s.sql_handle) as t 
    CROSS APPLY sys.dm_exec_query_plan(s.plan_handle) as p 
    CROSS APPLY query_plan.nodes('//sp:Object') as p1(n)
    WHERE n.value(N'@Index', N'sysname') IN (N'[IX1]', N'[IX2]')
)
SELECT 
    IndexName, 
    ProcedureName, 
    min(execution_count) as execution_count
FROM cte
GROUP BY ProcedureName, IndexName
ORDER BY ProcedureName, IndexName;
