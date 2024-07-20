-----------------------------------------------------------------
-- steps history performance analysis
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

;WITH cte AS (
	SELECT 
		j.name as JobName,
		h.step_name as step,
		h.run_status,
		s.subsystem,
		s.command,
		CAST(msdb.dbo.agent_datetime(run_date, run_time) as datetime2(0)) as RunDateTime,
		((run_duration/10000*3600 + (run_duration/100)%100*60 + run_duration%100 + 31 ) / 60) 
		as RunDurationMinutes
	FROM msdb.dbo.sysjobs j
	JOIN msdb.dbo.sysjobhistory h ON j.job_id = h.job_id 
	JOIN msdb.dbo.sysjobsteps s ON h.job_id = s.job_id
		AND h.step_id = s.step_id
	WHERE j.enabled = 1
	AND h.step_name NOT IN (N'(Job outcome)')
)
SELECT
	JobName, step,
	MIN(RunDateTime) as FirstRunDateTime,
	MAX(RunDateTime) as LastRunDateTime,
	DATEDIFF(day, MIN(RunDateTime), MAX(RunDateTime)) AS HistoryNbOfDays,
	DATENAME(weekday, MAX(RunDateTime)) as LastRunDay,
	AVG(RunDurationMinutes) AS AvgRunDurationMinutes,
	MAX(RunDurationMinutes) AS MaxRunDurationMinutes,
	COUNT(*) AS Executions,
	MIN(subsystem) as [type],
	TRIM(MIN(command)) as [cmd]
FROM cte
WHERE RunDurationMinutes > 0
GROUP BY JobName, step 
ORDER BY JobName, step
OPTION (RECOMPILE, MAXDOP 1);
