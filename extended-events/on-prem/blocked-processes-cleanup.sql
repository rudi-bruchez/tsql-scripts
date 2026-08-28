-----------------------------------------------------------------
-- stop and remove the blocked process report event session
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
-- Run this once the .xel files have been collected.
-- Do NOT run it before you have copied the files: dropping the
-- session does not delete them, but you lose the easy way to
-- locate them.
-----------------------------------------------------------------

-----------------------------------------------------------------
-- step 1 : stop the session
-----------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.dm_xe_sessions WHERE name = N'blocked_processes')
    ALTER EVENT SESSION [blocked_processes] ON SERVER STATE = STOP;
GO

-----------------------------------------------------------------
-- step 2 : drop the session definition
-----------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = N'blocked_processes')
    DROP EVENT SESSION [blocked_processes] ON SERVER;
GO

-----------------------------------------------------------------
-- step 3 : disable the blocked process monitor
--
-- Leave this out if you want to keep raising the event for
-- another session, or for a SQL Server Agent alert.
-----------------------------------------------------------------
EXEC sys.sp_configure N'show advanced options', N'1';
RECONFIGURE WITH OVERRIDE;
GO
EXEC sys.sp_configure N'blocked process threshold (s)', N'0';
RECONFIGURE WITH OVERRIDE;
GO
EXEC sys.sp_configure N'show advanced options', N'0';
RECONFIGURE WITH OVERRIDE;
GO

-----------------------------------------------------------------
-- step 4 : the .xel files are still on disk. Delete them from
-- the operating system, or use management/delete-event-files.sql
-----------------------------------------------------------------
