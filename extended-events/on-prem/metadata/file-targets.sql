-----------------------------------------------------------------
-- lists file targets and current file targets
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @path nvarchar(max) = (
		SELECT LEFT(CAST(SERVERPROPERTY('ErrorLogFileName') as nvarchar(max)), 
			LEN(CAST(SERVERPROPERTY('ErrorLogFileName') as nvarchar(max))) - LEN('ERRORLOG'))
	)

SELECT 
	s.name,
	IIF(running.name IS NULL, 0, 1) as running,
	st.execution_count as current_target_exec_count,
	st.execution_duration_ms as current_target_usage_ms,
	CASE WHEN CAST(field.value as nvarchar(1000)) NOT LIKE '%.xel' THEN CONCAT(@path, CAST(field.value as nvarchar(1000)), '*.xel')
		ELSE CAST(field.value as nvarchar(1000))
	END as [filename],
	CAST(st.target_data as xml).value('(/EventFileTarget/File)[1]/@name', 'nvarchar(max)') as [current_file]
FROM sys.server_event_sessions AS s
LEFT JOIN (
	sys.dm_xe_sessions AS running 
	JOIN sys.dm_xe_session_targets st ON running.address = st.event_session_address AND st.target_name = N'event_file'
	) ON running.name = s.name
JOIN sys.server_event_session_targets AS target ON s.event_session_id = target.event_session_id
INNER JOIN sys.dm_xe_object_columns AS col ON target.name = col.object_name AND col.column_type = 'customizable'
LEFT OUTER JOIN sys.server_event_session_fields AS field ON target.event_session_id = field.event_session_id AND target.target_id = field.object_id AND col.name = field.name
WHERE col.name = N'filename'
AND col.object_name = N'event_file'
ORDER BY s.name
OPTION (RECOMPILE, MAXDOP 1);