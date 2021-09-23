DECLARE @ExtendedEventsSessionName sysname = N'Perf2-procedure';
DECLARE @StartTime datetimeoffset;
DECLARE @EndTime datetimeoffset;
DECLARE @Offset int;

DROP TABLE IF EXISTS #xmlResults;
CREATE TABLE #xmlResults
(
      xeTimeStamp datetimeoffset NOT NULL
    , xeXML XML NOT NULL
);

SET @StartTime = DATEADD(HOUR, -4, GETDATE()); --modify this to suit your needs
SET @EndTime = GETDATE();
SET @Offset = DATEDIFF(MINUTE, GETDATE(), GETUTCDATE());
SET @StartTime = DATEADD(MINUTE, @Offset, @StartTime);
SET @EndTime = DATEADD(MINUTE, @Offset, @EndTime);

/*
SELECT StartTimeUTC = CONVERT(varchar(30), @StartTime, 127)
    , StartTimeLocal = CONVERT(varchar(30), DATEADD(MINUTE, 0 - @Offset, @StartTime), 120)
    , EndTimeUTC = CONVERT(varchar(30), @EndTime, 127)
    , EndTimeLocal = CONVERT(varchar(30), DATEADD(MINUTE, 0 - @Offset, @EndTime), 120);
*/

DECLARE @target_data xml;
SELECT @target_data = CONVERT(xml, target_data)
FROM sys.dm_xe_database_sessions AS s 
JOIN sys.dm_xe_database_session_targets AS t 
    ON t.event_session_address = s.address
WHERE s.name = @ExtendedEventsSessionName
    AND t.target_name = N'ring_buffer';

;WITH src AS 
(
    SELECT xeXML = xm.s.query('.')
    FROM @target_data.nodes('/RingBufferTarget/event') AS xm(s)
)
INSERT INTO #xmlResults (xeXML, xeTimeStamp)
SELECT src.xeXML
    , [xeTimeStamp] = src.xeXML.value('(/event/@timestamp)[1]', 'datetimeoffset(7)')
FROM src;

SELECT [TimeStamp] = CONVERT(varchar(30), DATEADD(MINUTE, 0 - @Offset, xr.xeTimeStamp), 120)
    , xr.xeXML
	, xr.xeXML.value('(/event/data[@name=''duration''])[1]', 'int') / 1000 as duration_ms
	, xr.xeXML.value('(/event/data[@name=''cpu_time''])[1]', 'int') / 1000 as cpu_ms
	, xr.xeXML.value('(/event/data[@name=''logical_reads''])[1]', 'int') as reads
	, xr.xeXML.value('(/event/data[@name=''row_count''])[1]', 'int') as [rowcount]
	, xr.xeXML.value('(/event/data[@name=''result'']/text)[1]', 'varchar(10)') as result
	, xr.xeXML.value('(/event/data[@name=''statement'']/value)[1]', 'nvarchar(max)') as stmt
	, xr.xeXML.query('/event/data[@name=''showplan_xml'']/value') as [plan]

FROM #xmlResults xr
WHERE xr.xeTimeStamp >= @StartTime
    AND xr.xeTimeStamp<= @EndTime
ORDER BY TimeStamp desc;