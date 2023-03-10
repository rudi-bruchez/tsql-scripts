-----------------------------------------------------------------
-- Remove a specific stored procedure plan from SQL Server cache
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT cp.plan_handle 
FROM sys.dm_exec_cached_plans cp 
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st 
WHERE OBJECT_NAME(st.objectid, st.dbid) = '<PROCEDURE NAME>';

-- paste the plan_handle here
DBCC FREEPROCCACHE (0x0123456....);

-- or, more modern

ALTER DATABASE SCOPED CONFIGURATION
CLEAR PROCEDURE_CACHE 0x0123456... -- paste the plan_handle here