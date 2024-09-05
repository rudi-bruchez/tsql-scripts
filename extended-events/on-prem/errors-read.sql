--------------------------------------------------------------------
-- read errors (exceptions) event session from event_file
--
-- rudi@babaluga.com, go ahead license
--------------------------------------------------------------------

DECLARE @file nvarchar(max) = (SELECT (CONVERT(xml, target_data)).value('(/EventFileTarget/File/@name)[1]', 'nvarchar(max)')
	FROM sys.dm_xe_sessions AS s 
	JOIN sys.dm_xe_session_targets AS t 
		ON t.event_session_address = s.address
	WHERE s.name = 'errors'
	AND t.target_name = N'event_file');

;WITH xe AS (
	SELECT
		[XMLData],
		[XMLData].value('(/event[@name=''error_reported'']/@timestamp)[1]','DATETIME')     AS [Timestamp],
		[XMLData].value('(/event/data[@name=''error_number'']/value)[1]','bigint')         AS [ErrorNumber],
		[XMLData].value('(/event/data[@name=''severity'']/value)[1]','smallint')           AS [Severity],
		[XMLData].value('(/event/data[@name=''message'']/value)[1]','varchar(max)')        AS [Message],
		[XMLData].value('(/event/action[@name=''username'']/value)[1]','sysname')          AS [username],
		[XMLData].value('(/event/action[@name=''database_name'']/value)[1]','sysname')     AS [db],
		[XMLData].value('(/event/action[@name=''client_hostname'']/value)[1]','sysname')   AS [hostname],
		[XMLData].value('(/event/action[@name=''client_app_name'']/value)[1]','sysname')  AS [app],
		[XMLData].value('(/event/action[@name=''sql_text'']/value)[1]','nvarchar(max)')    AS [Statement]
	FROM (SELECT
		OBJECT_NAME              AS [Event],
		CONVERT(XML, event_data) AS [XMLData]
	FROM sys.fn_xe_file_target_read_file (@file,NULL,NULL,NULL)) as errors
)
SELECT *
FROM xe
WHERE [Timestamp] > DATEADD(day, -1, CURRENT_TIMESTAMP);
