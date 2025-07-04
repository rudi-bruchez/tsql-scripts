-----------------------------------------------------------------
-- Purge history in MSDB database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;



USE [msdb]
GO

declare @dt datetime = DATEADD(month, -1, CURRENT_TIMESTAMP);

EXEC msdb.dbo.sp_delete_backuphistory @dt;
EXEC msdb.dbo.sp_purge_jobhistory  @oldest_date = @dt;
EXECUTE msdb..sp_maintplan_delete_log null, null, @dt;