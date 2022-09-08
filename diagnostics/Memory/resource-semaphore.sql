-----------------------------------------------------------------
-- 
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


--SELECT * FROM sys.dm_exec_query_resource_semaphores

SELECT 
	OBJECT_NAME(st.objectid, st.dbid),
	*
FROM sys.dm_exec_query_memory_grants mg
OUTER APPLY sys.dm_exec_sql_text(mg.sql_handle) st
WHERE mg.session_id <> @@SPID
ORDER BY mg.granted_memory_kb DESC
OPTION (RECOMPILE, MAXDOP 1);