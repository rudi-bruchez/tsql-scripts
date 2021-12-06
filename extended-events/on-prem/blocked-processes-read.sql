--------------------------------------------------------------------
-- read blocked process report event session from ring_buffer target
--
-- rudi@babaluga.com, go ahead license
--------------------------------------------------------------------

DECLARE @ExtendedEventsSessionName sysname = N'blocked_processes';

DECLARE @target_data xml;
SELECT @target_data = CONVERT(xml, target_data)
FROM sys.dm_xe_sessions AS s 
JOIN sys.dm_xe_session_targets AS t 
    ON t.event_session_address = s.address
WHERE s.name = @ExtendedEventsSessionName
    AND t.target_name = N'ring_buffer';

;WITH src AS 
(
    SELECT xeXML = xm.s.query('.')
    FROM @target_data.nodes('/RingBufferTarget/event') AS xm(s)
),
xmlResults AS (
	SELECT src.xeXML
		, CONVERT(varchar(30), DATEADD(MINUTE, 0 - DATEDIFF(MINUTE, GETDATE(), GETUTCDATE()), src.xeXML.value('(/event/@timestamp)[1]', 'datetimeoffset(7)')), 120) AS [TimeStamp]
		, src.xeXML.value('(/event/data[@name=''duration''])[1]', 'int') / 1000 as duration_ms
		, src.xeXML.value('(/event/data[@name=''database_id'']/value)[1]', 'smallint') as db
		, src.xeXML.value('(/event/data[@name=''object_id'']/value)[1]', 'int') as obj
		, src.xeXML.value('(/event/data[@name=''index_id'']/value)[1]', 'int') as idx
		, src.xeXML.value('(/event/data[@name=''lock_mode'']/text)[1]', 'varchar(10)') as lock
		, src.xeXML.query('/event/data[@name=''blocked_process'']') as blocked_process_report
		, src.xeXML.value('(/event/data[@name=''blocked_process'']/value/blocked-process-report/@monitorLoop)[1]', 'int') as monitor_loop
		, src.xeXML.value('(/event/data[@name=''blocked_process'']/value/blocked-process-report/blocked-process/process/@clientapp)[1]', 'nvarchar(128)') as blocked_app
		, src.xeXML.value('(/event/data[@name=''blocked_process'']/value/blocked-process-report/blocked-process/process/@hostname)[1]', 'nvarchar(max)') as blocked_host
		, src.xeXML.value('(/event/data[@name=''blocked_process'']/value/blocked-process-report/blocked-process/process/@loginname)[1]', 'nvarchar(128)') as blocked_login
		, src.xeXML.query('/event/data[@name=''blocked_process'']/value/blocked-process-report/blocked-process/process') as blocked_process
		, src.xeXML.value('(/event/data[@name=''blocked_process'']/value/blocked-process-report/blocked-process/process/@waittime)[1]', 'int') as wait_time_ms
		, src.xeXML.value('(/event/data[@name=''blocked_process'']/value/blocked-process-report/blocked-process/process/@waitresource)[1]', 'nvarchar(max)') as wait_resource
		, src.xeXML.value('(/event/data[@name=''blocked_process'']/value/blocked-process-report/blocked-process/process/executionStack/@sqlhandle)[1]', 'varbinary(max)') as blocked_sql_handle
		, src.xeXML.value('(/event/data[@name=''blocked_process'']/value/blocked-process-report/blocked-process/process/inputbuf)[1]', 'nvarchar(max)') as blocked_input_buffer
		, src.xeXML.query('/event/data[@name=''blocked_process'']/value/blocked-process-report/blocking-process/process') as blocking_process
		, src.xeXML.value('(/event/data[@name=''blocked_process'']/value/blocked-process-report/blocking-process/process/@clientapp)[1]', 'nvarchar(128)') as blocking_app
		, src.xeXML.value('(/event/data[@name=''blocked_process'']/value/blocked-process-report/blocking-process/process/@hostname)[1]', 'nvarchar(max)') as blocking_host
		, src.xeXML.value('(/event/data[@name=''blocked_process'']/value/blocked-process-report/blocking-process/process/@loginname)[1]', 'nvarchar(128)') as blocking_login
		, src.xeXML.value('(/event/data[@name=''blocked_process'']/value/blocked-process-report/blocking-process/process/inputbuf)[1]', 'nvarchar(max)') as blocking_input_buffer
	FROM src
)
SELECT TOP 50 
    xr.TimeStamp
   --,xr.xeXML
   ,xr.duration_ms
   ,DB_NAME(xr.db) AS db
   ,CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(xr.obj, xr.db)), '.', QUOTENAME(OBJECT_NAME(xr.obj, xr.db))) AS [object]
   ,i.name AS idx
   ,xr.lock
   ,xr.blocked_process_report
   ,xr.monitor_loop
   ,xr.blocked_process
   ,xr.blocked_app
   ,xr.blocked_host
   ,xr.blocked_login   
   ,xr.wait_time_ms / 1000 AS wait_time_sec
   ,xr.wait_resource
   ,xr.blocked_sql_handle
   ,xr.blocked_input_buffer
   ,xr.blocking_process
   ,xr.blocking_app
   ,xr.blocking_host
   ,xr.blocking_login   
   ,xr.blocking_input_buffer
FROM xmlResults xr
LEFT JOIN sys.indexes i ON xr.obj = i.object_id AND xr.idx = i.index_id
ORDER BY duration_ms desc;