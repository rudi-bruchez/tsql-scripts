-----------------------------------------------------------------
-- monitor a running shrink operation
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
SELECT 
	t.text,
	r.start_time,
	r.status,
	DB_NAME(r.database_id) as [db],
	r.wait_type,
	r.wait_time,
	r.last_wait_type,
	r.percent_complete,
	r.estimated_completion_time,
	r.total_elapsed_time
FROM sys.dm_exec_requests r
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) as t
WHERE r.command = N'DbccFilesCompact';