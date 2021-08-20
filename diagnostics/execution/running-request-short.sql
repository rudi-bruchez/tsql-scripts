-- short version
SELECT r.session_id, t.text, r.status, DB_NAME(database_id) as db, wait_type, wait_time, last_wait_type, open_transaction_count, p.query_plan
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) p
WHERE r.session_id > 50 AND r.session_id <> @@SPID
AND last_wait_type NOT IN ('SP_SERVER_DIAGNOSTICS_SLEEP')
OPTION (RECOMPILE, MAXDOP 1);
