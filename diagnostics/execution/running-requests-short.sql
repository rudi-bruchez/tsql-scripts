-----------------------------------------------------------------
-- lists running requests with query text, short version
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
    r.session_id, 
    t.text, 
    r.status, 
    DB_NAME(database_id) as db, 
    r.total_elapsed_time as running_ms,
    COALESCE(wait_type, '') as wait_type,  -- easier to read than with NULL
    wait_time, 
    last_wait_type, 
    open_transaction_count, 
    p.query_plan
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) p
WHERE r.session_id > 50 AND r.session_id <> @@SPID
AND last_wait_type NOT IN ('SP_SERVER_DIAGNOSTICS_SLEEP', 'XE_LIVE_TARGET_TVF')
OPTION (RECOMPILE, MAXDOP 1);
