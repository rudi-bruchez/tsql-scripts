-----------------------------------------------------------------
-- read blocked process report .xel files collected elsewhere
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
-- Use this to analyse files sent by a customer, on your own
-- instance. To read the files of a session running on the local
-- instance, use blocked-processes-read.sql instead.
--
-- Unzip the files in a directory readable by the SQL Server
-- service account of the instance you are running this on.
--
-- database_id and object_id are NOT resolved, since the metadata
-- belongs to the source instance. Use the report XML and the
-- database_id / object_id columns, or run the resolution on the
-- source instance.
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-------------------------------------------------------------
-- SET THE PATH TO THE .xel FILES HERE (wildcard is supported)
DECLARE @file nvarchar(max) = N'C:\temp\blocked_processes*.xel';
-------------------------------------------------------------

DECLARE @last int = 500;

-- the timestamps below are UTC, as recorded on the source
-- instance; set the offset of the source server to convert them
DECLARE @utc_offset_hours int = 0;

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
       DATEADD(HOUR, @utc_offset_hours, xe.ts_utc)                                    AS [source_time],
       xe.XMLData.value('(/event/data[@name="duration"]/value)[1]', 'bigint') / 1000000 AS duration_sec,
       xe.XMLData.value('(/event/data[@name="lock_mode"]/text)[1]', 'varchar(20)')    AS lock_mode,
       xe.XMLData.value('(/event/data[@name="database_id"]/value)[1]', 'smallint')    AS database_id,
       xe.XMLData.value('(/event/data[@name="object_id"]/value)[1]', 'int')           AS object_id,
       xe.XMLData.value('(/event/data[@name="index_id"]/value)[1]', 'int')            AS index_id,
       xe.report.value('(blocked-process/process/@currentdbname)[1]', 'nvarchar(128)') AS blocked_database,
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
