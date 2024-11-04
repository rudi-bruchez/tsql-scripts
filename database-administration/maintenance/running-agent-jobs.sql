-----------------------------------------------------------------
-- Running SQL Server Agent Jobs
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    j.name AS job_name,
    ja.start_execution_date AS start_time,
    DATEDIFF(MINUTE, ja.start_execution_date, GETDATE()) AS duration_minutes
FROM msdb.dbo.sysjobactivity ja 
INNER JOIN msdb.dbo.sysjobs j 
    ON j.job_id = ja.job_id
WHERE 
    ja.start_execution_date IS NOT NULL
    AND ja.stop_execution_date IS NULL
    AND ja.session_id = (SELECT MAX(session_id) FROM msdb.dbo.sysjobactivity)
ORDER BY 
    start_time DESC
OPTION (RECOMPILE, MAXDOP 1);