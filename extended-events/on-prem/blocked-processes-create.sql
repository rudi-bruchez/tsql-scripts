--------------------------------------------------------------------
-- create blocked process report event session
--
-- rudi@babaluga.com, go ahead license
--------------------------------------------------------------------

-- configure blocked process threshold to 10 seconds
EXEC sys.sp_configure N'show advanced options', N'1'
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'blocked process threshold (s)', N'10'
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'show advanced options', N'0'  
RECONFIGURE WITH OVERRIDE
GO

-- create the xevent
CREATE EVENT SESSION [blocked_processes] ON SERVER 
ADD EVENT sqlserver.blocked_process_report
ADD TARGET package0.event_file(SET filename=N'blocked_processes',max_file_size=(50))
-- ADD TARGET package0.ring_buffer
WITH (STARTUP_STATE=OFF)
GO

-- start the session
ALTER EVENT SESSION [blocked_processes] ON SERVER STATE=START;
-- stop the session
/*
ALTER EVENT SESSION [blocked_processes] ON SERVER STATE=STOP;
*/