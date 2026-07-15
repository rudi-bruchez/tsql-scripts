-----------------------------------------------------------------
-- Lists all SQL Server agent jobs and the database they belong to
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	j.name as job, 
	st.step_name, 
	st.database_name
FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.sysjobsteps st ON j.job_id = st.job_id
WHERE st.subsystem = N'TSQL'
ORDER BY job, st.step_id
OPTION (RECOMPILE, MAXDOP 1);