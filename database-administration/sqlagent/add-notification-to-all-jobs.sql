-----------------------------------------------------------------
-- Update all jobs to add email notification
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
GO

USE [msdb]
GO

DECLARE @operator sysname = 
(
	SELECT TOP 1 name, *
	FROM msdb.dbo.sysoperators
	WHERE enabled = 1
	AND email_address IS NOT NULL
)

DECLARE cur CURSOR
FAST_FORWARD
FOR 
	SELECT name
	FROM msdb.dbo.sysjobs
	WHERE [enabled] = 1
	AND notify_level_email = 0
	AND originating_server_id = 0;


DECLARE @jobname sysname
OPEN cur

FETCH NEXT FROM cur INTO @jobname
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		EXEC msdb.dbo.sp_update_job @job_name = @jobname, 
			@notify_level_email=2, 
			@notify_level_page=2, 
			@notify_email_operator_name = @operator
	END
	FETCH NEXT FROM cur INTO @name
END

CLOSE cur
DEALLOCATE cur
GO
