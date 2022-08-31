-----------------------------------------------------------------
-- get jobs and step history for steps that ran for more
-- than one minute.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

;WITH cte AS (
	SELECT 
		j.name as JobName,
		h.step_name as step,
		h.run_status,
		CAST(msdb.dbo.agent_datetime(run_date, run_time) as datetime2(0)) as RunDateTime,
		((run_duration/10000*3600 + (run_duration/100)%100*60 + run_duration%100 + 31 ) / 60) 
		as RunDurationMinutes
	FROM msdb.dbo.sysjobs j
	JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id 
	WHERE j.enabled = 1
	AND h.step_name NOT IN (N'(Job outcome)')
)
SELECT *
FROM cte
WHERE RunDurationMinutes > 0
ORDER BY JobName, RunDateTime DESC
OPTION (RECOMPILE, MAXDOP 1);
