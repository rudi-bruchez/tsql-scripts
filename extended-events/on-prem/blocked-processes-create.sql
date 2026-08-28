-----------------------------------------------------------------
-- create the blocked process report event session
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
-- Requires: ALTER ANY EVENT SESSION, and ALTER SETTINGS (or sysadmin)
--           for the sp_configure part.
--
-- The blocked_process_report event is ONLY raised if the
-- 'blocked process threshold (s)' setting is greater than 0.
-- Step 1 is therefore mandatory.
-----------------------------------------------------------------

-----------------------------------------------------------------
-- step 1 : set the blocked process threshold
--
-- The event is raised when a session has been blocked for at
-- least this number of seconds, and then once per monitor loop
-- for as long as the block lasts.
--
-- 0  = feature disabled (default)
-- 5  = minimum useful value, verbose on a busy instance
-- 10 = good default for a diagnostic collection
-- 30 = only the long, painful blocks
-----------------------------------------------------------------
EXEC sys.sp_configure N'show advanced options', N'1';
RECONFIGURE WITH OVERRIDE;
GO
EXEC sys.sp_configure N'blocked process threshold (s)', N'10';
RECONFIGURE WITH OVERRIDE;
GO
EXEC sys.sp_configure N'show advanced options', N'0';
RECONFIGURE WITH OVERRIDE;
GO

-----------------------------------------------------------------
-- step 2 : create the session
--
-- The event file is written to the SQL Server error log
-- directory. Replace the filename with a full path
-- (N'D:\xevents\blocked_processes.xel') to write it elsewhere:
-- the SQL Server service account needs write access to it.
--
-- max_file_size    : 50 MB per file
-- max_rollover_files : 10 files kept, so 500 MB at most on disk
-----------------------------------------------------------------
CREATE EVENT SESSION [blocked_processes] ON SERVER
ADD EVENT sqlserver.blocked_process_report
ADD TARGET package0.event_file (
    SET filename = N'blocked_processes',
        max_file_size = (50),
        max_rollover_files = (10)
)
WITH (
    MAX_DISPATCH_LATENCY = 30 SECONDS,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    STARTUP_STATE = OFF
);
GO

-----------------------------------------------------------------
-- step 3 : start the session
-----------------------------------------------------------------
ALTER EVENT SESSION [blocked_processes] ON SERVER STATE = START;
GO

-----------------------------------------------------------------
-- check that the session is running and where it writes
-----------------------------------------------------------------
SELECT s.name,
       s.create_time,
       CAST(t.target_data AS xml).value('(/EventFileTarget/File/@name)[1]', 'nvarchar(max)') AS current_file
FROM sys.dm_xe_sessions AS s
JOIN sys.dm_xe_session_targets AS t
    ON t.event_session_address = s.address
WHERE s.name = N'blocked_processes'
  AND t.target_name = N'event_file';

-- to stop the session and clean everything up,
-- see blocked-processes-cleanup.sql
