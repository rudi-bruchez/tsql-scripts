-----------------------------------------------------------------
-- disable all SQL agent jobs
--
-- Goes through sp_update_job so that SQL Agent refreshes its
-- cache: an UPDATE of msdb.dbo.sysjobs leaves the jobs running
-- on schedule. Prints the name of each job it disables.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @job_id uniqueidentifier, @job_name sysname;

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
	SELECT job_id, name
	FROM msdb.dbo.sysjobs
	WHERE enabled = 1;

OPEN cur;
FETCH NEXT FROM cur INTO @job_id, @job_name;
WHILE (@@fetch_status = 0)
BEGIN
	PRINT CONCAT('disabling ', QUOTENAME(@job_name));
	EXEC msdb.dbo.sp_update_job @job_id = @job_id, @enabled = 0;
	FETCH NEXT FROM cur INTO @job_id, @job_name;
END

CLOSE cur;
DEALLOCATE cur;
