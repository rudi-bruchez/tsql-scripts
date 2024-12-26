-----------------------------------------------------------------
-- Blocking Graph view
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

CREATE OR ALTER VIEW dbo.vBlockingGraph
AS
WITH sessions AS (
	SELECT
	    s.session_id
	   ,s.login_time
	   ,s.host_name
	   ,s.program_name
	   ,s.login_name
	   ,s.status as session_status
	   ,s.last_request_end_time
	   ,s.open_transaction_count as transactions
	   ,r.request_id
	   ,r.status as request_status
	   ,r.command
	   --,r.sql_handle
	   ,DB_NAME(COALESCE(r.database_id, s.database_id)) as db
	   ,r.wait_type
	   ,r.wait_time
	   ,r.wait_resource
	   ,r.blocking_session_id
	FROM sys.dm_exec_sessions s
	LEFT JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
	WHERE s.is_user_process = 1
	AND s.session_id <> @@SPID
),
blocking_blocked_sessions AS (
	SELECT s.session_id
	FROM sessions s
	WHERE NULLIF(blocking_session_id, 0) IS NOT NULL
	UNION 
	SELECT NULLIF(blocking_session_id, 0)
	FROM sessions s
),
blocking_graph AS (
	SELECT session_id, blocking_session_id, 0 as level
	FROM sessions s
	WHERE s.session_id IN (SELECT session_id FROM blocking_blocked_sessions)
	AND blocking_session_id IS NULL

	UNION ALL

	SELECT s.session_id, s.blocking_session_id, level + 1
	FROM sessions s
	JOIN blocking_graph bg ON s.blocking_session_id = bg.session_id

)
SELECT TOP 100 PERCENT
	bg.level, s.*, TRIM(inputbuffer.event_info) as last_query
	--CONCAT_WS(' ', REPLICATE('-', bg.level * 2), QUOTENAME(s.session_id, '('), s.program_name, TRIM(inputbuffer.event_info)) as graph
FROM sessions s
JOIN blocking_graph bg ON s.session_id = bg.session_id
OUTER APPLY sys.dm_exec_input_buffer (s.session_id , s.request_id) as inputbuffer
ORDER BY bg.level
--OPTION (MAXDOP 1, RECOMPILE)
;
GO
