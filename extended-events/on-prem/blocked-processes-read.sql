-----------------------------------------------------------------
-- read the blocked process report event session
-- from the event_file target of the running session
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
-- To read .xel files collected on another instance, use
-- blocked-processes-read-file.sql instead.
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
    WHERE s.name = N'blocked_processes');

IF @configured IS NULL
BEGIN
    RAISERROR(N'The blocked_processes session does not exist, or has no event_file target.', 16, 1);
    RETURN;
END

DECLARE @file nvarchar(max) =
    CASE WHEN @configured LIKE N'%.xel' THEN REPLACE(@configured, N'.xel', N'*.xel')
         ELSE CONCAT(@configured, N'*.xel')
    END;

-- a relative file name lands in the SQL Server error log directory
IF CHARINDEX(CHAR(92), @file) = 0
    SET @file = CONCAT(
        LEFT(CAST(SERVERPROPERTY('ErrorLogFileName') AS nvarchar(max)),
             LEN(CAST(SERVERPROPERTY('ErrorLogFileName') AS nvarchar(max))) - LEN('ERRORLOG')),
        @file);

;WITH xe AS (
    SELECT ts_utc,
           XMLData,
           XMLData.query('(/event/data[@name="blocked_process"]/value/blocked-process-report)[1]') AS report
    FROM (
        SELECT timestamp_utc          AS ts_utc,
               CONVERT(xml, event_data) AS XMLData
        FROM sys.fn_xe_file_target_read_file(@file, NULL, NULL, NULL)
    ) AS src
)
SELECT TOP (@last)
       DATEADD(MINUTE, DATEDIFF(MINUTE, GETUTCDATE(), GETDATE()), xe.ts_utc) AS [local_time],
       xe.XMLData.value('(/event/data[@name="duration"]/value)[1]', 'bigint') / 1000000 AS duration_sec,
       xe.XMLData.value('(/event/data[@name="lock_mode"]/text)[1]', 'varchar(20)')      AS lock_mode,
       DB_NAME(xe.XMLData.value('(/event/data[@name="database_id"]/value)[1]', 'smallint')) AS [database],
       CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(
                  xe.XMLData.value('(/event/data[@name="object_id"]/value)[1]', 'int'),
                  xe.XMLData.value('(/event/data[@name="database_id"]/value)[1]', 'smallint'))), N'.',
              QUOTENAME(OBJECT_NAME(
                  xe.XMLData.value('(/event/data[@name="object_id"]/value)[1]', 'int'),
                  xe.XMLData.value('(/event/data[@name="database_id"]/value)[1]', 'smallint')))) AS [object],
       xe.XMLData.value('(/event/data[@name="index_id"]/value)[1]', 'int')            AS index_id,
       -- victim
       xe.report.value('(blocked-process/process/@spid)[1]', 'int')                   AS blocked_spid,
       xe.report.value('(blocked-process/process/@waittime)[1]', 'bigint') / 1000     AS blocked_wait_sec,
       xe.report.value('(blocked-process/process/@waitresource)[1]', 'nvarchar(500)') AS blocked_wait_resource,
       xe.report.value('(blocked-process/process/@isolationlevel)[1]', 'nvarchar(100)') AS blocked_isolation,
       xe.report.value('(blocked-process/process/@loginname)[1]', 'nvarchar(128)')    AS blocked_login,
       xe.report.value('(blocked-process/process/@hostname)[1]', 'nvarchar(128)')     AS blocked_host,
       xe.report.value('(blocked-process/process/@clientapp)[1]', 'nvarchar(128)')    AS blocked_app,
       xe.report.value('(blocked-process/process/inputbuf)[1]', 'nvarchar(max)')      AS blocked_input_buffer,
       -- culprit
       xe.report.value('(blocking-process/process/@spid)[1]', 'int')                  AS blocking_spid,
       -- 'sleeping' with an open transaction means the application
       -- opened a transaction and did not commit it
       xe.report.value('(blocking-process/process/@status)[1]', 'nvarchar(30)')       AS blocking_status,
       xe.report.value('(blocking-process/process/@trancount)[1]', 'int')             AS blocking_trancount,
       xe.report.value('(blocking-process/process/@transactionname)[1]', 'nvarchar(128)') AS blocking_transaction,
       xe.report.value('(blocking-process/process/@lastbatchstarted)[1]', 'nvarchar(30)')   AS blocking_last_batch_started,
       xe.report.value('(blocking-process/process/@lastbatchcompleted)[1]', 'nvarchar(30)') AS blocking_last_batch_completed,
       xe.report.value('(blocking-process/process/@loginname)[1]', 'nvarchar(128)')   AS blocking_login,
       xe.report.value('(blocking-process/process/@hostname)[1]', 'nvarchar(128)')    AS blocking_host,
       xe.report.value('(blocking-process/process/@clientapp)[1]', 'nvarchar(128)')   AS blocking_app,
       xe.report.value('(blocking-process/process/inputbuf)[1]', 'nvarchar(max)')     AS blocking_input_buffer,
       xe.report                                                                      AS blocked_process_report
FROM xe
ORDER BY xe.ts_utc DESC
OPTION (RECOMPILE, MAXDOP 1);
