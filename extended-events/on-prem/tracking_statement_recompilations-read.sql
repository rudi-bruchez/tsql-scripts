--------------------------------------------------------------------
-- read recompilations event session
--
-- rudi@babaluga.com, go ahead license
--------------------------------------------------------------------

DECLARE @ExtendedEventsSessionName sysname = N'tracking_statement_recompilations';

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
		, src.xeXML.value('(/event/data[@name=''recompile_cause'']/text)[1]', 'varchar(128)') as cause
		, src.xeXML.value('(/event/data[@name=''source_database_id'']/value)[1]', 'smallint') as db
		, src.xeXML.value('(/event/data[@name=''object_id'']/value)[1]', 'int') as obj
		, src.xeXML.value('(/event/data[@name=''object_type'']/text)[1]', 'varchar(128)') as obj_type
		, src.xeXML.value('(/event/data[@name=''statement'']/value)[1]', 'nvarchar(max)') as statement
		, src.xeXML.value('(/event/action[@name=''client_app_name'']/value)[1]', 'nvarchar(128)') as client_app_name
		, src.xeXML.value('(/event/action[@name=''client_hostname'']/value)[1]', 'nvarchar(128)') as client_hostname
		, src.xeXML.value('(/event/action[@name=''username'']/value)[1]', 'nvarchar(128)') as username
	FROM src
)
SELECT --TOP 50 
    xr.TimeStamp
   --,xr.xeXML
   ,xr.cause
   ,DB_NAME(xr.db) AS db
   ,CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(xr.obj, xr.db)), '.', QUOTENAME(OBJECT_NAME(xr.obj, xr.db))) AS [object]
   ,obj_type
   ,xr.statement
   ,xr.client_app_name
   ,xr.client_hostname,
   xr.username
FROM xmlResults xr
ORDER BY [TimeStamp] desc;
