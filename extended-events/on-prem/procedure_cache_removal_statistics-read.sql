--------------------------------------------------------------------
-- read recompilations event session
--
-- rudi@babaluga.com, go ahead license
--------------------------------------------------------------------

DECLARE @ExtendedEventsSessionName sysname = N'procedure_removal_statistics';

DECLARE @target_data xml;
SELECT @target_data = CONVERT(xml, target_data)
FROM sys.dm_xe_sessions AS s 
JOIN sys.dm_xe_session_targets AS t 
    ON t.event_session_address = s.address
WHERE s.name = @ExtendedEventsSessionName
    AND t.target_name = N'ring_buffer';

;WITH src AS 
(
    SELECT 
		xm.s.query('.') as xeXML,
		CAST(xm.s.query('.').value('(/event/data[@name=''execution_statistics'']/value)[1]', 'nvarchar(max)') as xml) as execution_statistics
    FROM @target_data.nodes('/RingBufferTarget/event') AS xm(s)
),
xmlResults AS (
	SELECT src.xeXML
		, CONVERT(varchar(30), DATEADD(MINUTE, 0 - DATEDIFF(MINUTE, GETDATE(), GETUTCDATE()), src.xeXML.value('(/event/@timestamp)[1]', 'datetimeoffset(7)')), 120) AS [TimeStamp]
		, src.xeXML.value('(/event/data[@name=''recompile_cause'']/text)[1]', 'varchar(128)') as cause
		, src.xeXML.value('(/event/data[@name=''sql_handle'']/value)[1]', 'varbinary(max)') as sql_handle
		, src.xeXML.value('(/event/data[@name=''compiled_object_id'']/value)[1]', 'int') as obj
		, src.xeXML.value('(/event/data[@name=''compiled_object_type'']/text)[1]', 'varchar(128)') as obj_type
		, src.xeXML.value('(/event/data[@name=''statement'']/value)[1]', 'nvarchar(max)') as statement
		, src.execution_statistics
		, src.execution_statistics.value('(/ProcedureExecutionStats/GeneralStats[@CachedTime])[1]', 'datetime') as cached_time -- to correct
	FROM src
)
SELECT --TOP 50 
    xr.TimeStamp
   --,xr.xeXML
   ,xr.cause
   ,xr.sql_handle
   --,CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(xr.obj, xr.db)), '.', QUOTENAME(OBJECT_NAME(xr.obj, xr.db))) AS [object]
   ,xr.obj
   ,OBJECT_NAME(xr.obj) as [object_name] -- hum, how to find the database ? sys.dm_exec_sql_text, but it is failing
   ,xr.obj_type
   ,xr.statement
   ,xr.execution_statistics
   --,xr.cached_time
   --,st.objectid
   --,st.dbid
   --,st.text
FROM xmlResults xr
--OUTER APPLY sys.dm_exec_sql_text(COALESCE(xr.sql_handle, 0)) st
ORDER BY [TimeStamp] desc;
