-----------------------------------------------------------------
-- read the lock_escalations event session
-- (see lock-escalation-create.sql)
-- SQL Server 2017+ (timestamp_utc)
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @last int = 100;

-- resolve the file name pattern configured on the session,
-- so that all rollover files are read, running or not
DECLARE @configured nvarchar(1000) = (
    SELECT CAST(f.value AS nvarchar(1000))
    FROM sys.server_event_sessions AS s
    JOIN sys.server_event_session_targets AS t
        ON t.event_session_id = s.event_session_id AND t.name = N'event_file'
    JOIN sys.server_event_session_fields AS f
        ON f.event_session_id = t.event_session_id AND f.object_id = t.target_id AND f.name = N'filename'
    WHERE s.name = N'lock_escalations');

IF @configured IS NULL
BEGIN
    RAISERROR(N'The lock_escalations session does not exist, or has no event_file target.', 16, 1);
    RETURN;
END

DECLARE @file nvarchar(max) =
    CASE WHEN @configured LIKE N'%.xel' THEN REPLACE(@configured, N'.xel', N'*.xel')
         ELSE CONCAT(@configured, N'*.xel')
    END;

-- a relative file name lands in the SQL Server error log directory
IF CHARINDEX(CHAR(92), @file) = 0 AND LEFT(@file, 1) <> N'/'
    SET @file = CONCAT(
        LEFT(CAST(SERVERPROPERTY('ErrorLogFileName') AS nvarchar(max)),
             LEN(CAST(SERVERPROPERTY('ErrorLogFileName') AS nvarchar(max))) - LEN('ERRORLOG')),
        @file);

;WITH xe AS (
    SELECT timestamp_utc            AS ts_utc,
           CONVERT(xml, event_data) AS XMLData
    FROM sys.fn_xe_file_target_read_file(@file, NULL, NULL, NULL)
    WHERE [object_name] = N'lock_escalation'
),
ev AS (
    SELECT xe.ts_utc,
           xe.XMLData.value('(/event/data[@name="database_id"]/value)[1]', 'int')             AS database_id,
           xe.XMLData.value('(/event/data[@name="object_id"]/value)[1]', 'int')               AS [object_id],
           xe.XMLData.value('(/event/data[@name="hobt_id"]/value)[1]', 'bigint')              AS hobt_id,
           xe.XMLData.value('(/event/data[@name="resource_type"]/text)[1]', 'nvarchar(60)')   AS resource_type,
           xe.XMLData.value('(/event/data[@name="mode"]/text)[1]', 'nvarchar(60)')            AS lock_mode,
           xe.XMLData.value('(/event/data[@name="escalation_cause"]/text)[1]', 'nvarchar(60)') AS escalation_cause,
           xe.XMLData.value('(/event/data[@name="escalated_lock_count"]/value)[1]', 'int')    AS escalated_lock_count,
           xe.XMLData.value('(/event/data[@name="hobt_lock_count"]/value)[1]', 'int')         AS hobt_lock_count,
           xe.XMLData.value('(/event/action[@name="session_id"]/value)[1]', 'int')            AS session_id,
           xe.XMLData.value('(/event/action[@name="database_name"]/value)[1]', 'sysname')     AS [database],
           xe.XMLData.value('(/event/action[@name="client_app_name"]/value)[1]', 'nvarchar(128)') AS app,
           xe.XMLData.value('(/event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)')    AS sql_text
    FROM xe
)
SELECT TOP (@last)
       DATEADD(MINUTE, DATEDIFF(MINUTE, GETUTCDATE(), GETDATE()), ev.ts_utc) AS [local_time],
       ev.[database],
       CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(ev.[object_id], ev.database_id)), N'.',
              QUOTENAME(OBJECT_NAME(ev.[object_id], ev.database_id))) AS [object],
       ev.hobt_id,
       ev.resource_type,
       ev.lock_mode,
       ev.escalation_cause,
       ev.escalated_lock_count,
       ev.hobt_lock_count,
       ev.session_id,
       ev.app,
       ev.sql_text
FROM ev
ORDER BY ev.ts_utc DESC
OPTION (RECOMPILE, MAXDOP 1);
