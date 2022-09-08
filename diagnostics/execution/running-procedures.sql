-----------------------------------------------------------------
-- list currently running stored procedures
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
	DB_NAME(er.database_id) AS [db], 
	CONCAT(OBJECT_SCHEMA_NAME(st.objectid, er.database_id), '.', object_name(st.objectid, er.database_id)) as ProcName, 
	DATEDIFF(SECOND, er.start_time, CURRENT_TIMESTAMP) AS running_seconds,
	CONCAT('KILL ', qs.session_id) AS [kill], -- if we need to kill the session
	SUBSTRING(detail.text, er.statement_start_offset / 2, (er.statement_end_offset - er.statement_start_offset) / 2) as [statement]
FROM sys.dm_exec_connections as qs
JOIN sys.dm_exec_requests AS er ON qs.session_id = er.session_id AND qs.connection_id = er.connection_id
CROSS APPLY sys.dm_exec_sql_text(qs.most_recent_sql_handle) st 
OUTER APPLY sys.dm_exec_sql_text(er.plan_handle) detail
OPTION (RECOMPILE, MAXDOP 1);