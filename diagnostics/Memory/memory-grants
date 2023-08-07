-----------------------------------------------------------------
-- Look at live memory grants
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
    s.login_time,
    s.login_name,
    s.host_name,
    s.program_name,
    DB_NAME(r.database_id) as [db],
    s.total_elapsed_time,
    s.logical_reads,
    OBJECT_NAME(st.objectid, r.database_id) as [object],
    st.text,
    qp.query_plan,
    mg.*
FROM sys.dm_exec_query_memory_grants mg
JOIN sys.dm_exec_sessions s ON mg.session_id = s.session_id
JOIN sys.dm_exec_requests r ON mg.session_id = r.session_id
    AND mg.request_id = r.request_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) st
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) qp
WHERE s.session_id <> @@SPID
OPTION (RECOMPILE, MAXDOP 1);