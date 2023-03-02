-----------------------------------------------------------------
-- Find a job by its JobId
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @JobId UNIQUEIDENTIFIER = 0xEC2BE659904E514AA598A952F820ECA5; -- change this to your JobId

SELECT j.name AS [Job], 
       s.step_name AS [Step], 
       s.step_id AS [Step Id], 
       s.command AS [Command], 
       sj.run_requested_date AS [Last execution]
FROM msdb.dbo.sysjobs j 
JOIN msdb.dbo.sysjobsteps s ON j.job_id = s.job_id 
JOIN msdb.dbo.sysjobactivity sj ON sj.job_id = j.job_id 
WHERE j.job_id = @JobId
ORDER BY sj.run_requested_date DESC
OPTION (RECOMPILE, MAXDOP 1);