-- list current file targets

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	s.name as [session], 
	st.execution_count,
	st.execution_duration_ms,
	CAST(st.target_data as xml).value('(/EventFileTarget/File)[1]/@name', 'nvarchar(max)') as [file]
FROM sys.dm_xe_sessions s
JOIN sys.dm_xe_session_targets st ON s.address = st.event_session_address
WHERE st.target_name = N'event_file'
ORDER BY s.name
OPTION (RECOMPILE, MAXDOP 1);
