-----------------------------------------------------------------
-- read aborted queries
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @last int = 100;

DECLARE @file nvarchar(max) = (SELECT (CONVERT(xml, target_data)).value('(/EventFileTarget/File/@name)[1]', 'nvarchar(max)')
    FROM sys.dm_xe_sessions AS s 
    JOIN sys.dm_xe_session_targets AS t 
        ON t.event_session_address = s.address
    WHERE s.name = 'timeouts'
    AND t.target_name = N'event_file');

;WITH xe AS (
    SELECT
        [Event],
        [ts_utc],
        --[XMLData],
        [XMLData].value('(/event/data[@name=''cpu_time'']/value)[1]','bigint') / 1000      AS [cpu_ms],
        [XMLData].value('(/event/data[@name=''duration'']/value)[1]','bigint') / 1000      AS [duration_ms],
        [XMLData].value('(/event/data[@name=''row_count'']/value)[1]','bigint')             AS [rowcount],
        [XMLData].value('(/event/action[@name=''username'']/value)[1]','sysname')          AS [username],
        [XMLData].value('(/event/action[@name=''database_name'']/value)[1]','sysname')     AS [db],
        [XMLData].value('(/event/action[@name=''client_hostname'']/value)[1]','sysname')   AS [hostname],
        [XMLData].value('(/event/action[@name=''client_app_name'']/value)[1]','sysname')   AS [app],
        COALESCE([XMLData].value('(/event/data[@name=''statement'']/value)[1]','nvarchar(max)'),     
                 [XMLData].value('(/event/data[@name=''batch_text'']/value)[1]','nvarchar(max)'))
                                                                                            AS [Statement]
    FROM (SELECT
        [object_name]            AS [Event],
        [timestamp_utc]          AS [ts_utc],
        CONVERT(XML, event_data) AS [XMLData]
    FROM sys.fn_xe_file_target_read_file (@file,NULL,NULL,NULL)) as timeouts
    WHERE [XMLData].value('(/event/data[@name=''result'']/value)[1]','tinyint') = 2 -- abort
)
SELECT *
FROM xe
ORDER BY ts_utc DESC
OFFSET 0 ROWS FETCH NEXT @last ROWS ONLY
OPTION (RECOMPILE, MAXDOP 1);