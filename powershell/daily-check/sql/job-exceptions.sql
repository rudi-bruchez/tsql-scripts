-----------------------------------------------------------------
-- Daily Check: SQL Agent Job Exceptions
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @LookbackHours   INT = 26;
DECLARE @PercentThreshold INT = 50;
DECLARE @MinutesThreshold INT = 5;
DECLARE @BaselineDays     INT = 30;
-- PowerShell will string-replace these declarations.

DECLARE @RunDateStart DATETIME = DATEADD(hour, -@LookbackHours, GETDATE());
DECLARE @StartDate INT = CONVERT(INT, CONVERT(VARCHAR(8), @RunDateStart, 112));
DECLARE @StartTime INT = DATEPART(hour,@RunDateStart)*10000 + DATEPART(minute,@RunDateStart)*100 + DATEPART(second,@RunDateStart);

WITH JobAverages AS (
    SELECT 
        job_id,
        CAST(AVG(CAST(((run_duration/10000)*3600 + ((run_duration%10000)/100)*60 + (run_duration%100)) AS DECIMAL(18,2))) AS INT) as AvgDurationSeconds,
        COUNT(*) as SampleCount
    FROM msdb.dbo.sysjobhistory
    WHERE run_date >= CONVERT(INT, CONVERT(VARCHAR(8), GETDATE() - @BaselineDays, 112))
    AND step_id = 0
    AND run_status = 1
    GROUP BY job_id
    HAVING COUNT(*) >= 5
)
SELECT 
    @@servername AS ServerName,
    j.name AS JobName,
    ISNULL(h.step_name, 'Job Outcome') AS StepName,
    CASE h.run_status WHEN 0 THEN 'Failed' WHEN 1 THEN 'Succeeded' WHEN 3 THEN 'Canceled' ELSE 'Unknown' END AS Status,
    DATETIMEFROMPARTS(h.run_date/10000, (h.run_date%10000)/100, h.run_date%100, h.run_time/10000, (h.run_time%10000)/100, h.run_time%100, 0) AS RunDateTime,
    ((h.run_duration/10000)*3600 + ((h.run_duration%10000)/100)*60 + (h.run_duration%100)) AS ActualDurationSeconds,
    a.AvgDurationSeconds,
    a.SampleCount,
    h.message AS Message
FROM msdb.dbo.sysjobhistory h
JOIN msdb.dbo.sysjobs j ON h.job_id = j.job_id
LEFT JOIN JobAverages a ON h.job_id = a.job_id
WHERE (h.run_date > @StartDate OR (h.run_date = @StartDate AND h.run_time >= @StartTime))
AND (
    (h.run_status IN (0, 3))
    OR 
    (h.step_id = 0 AND h.run_status = 1 
     AND a.AvgDurationSeconds IS NOT NULL
     AND ((h.run_duration/10000)*3600 + ((h.run_duration%10000)/100)*60 + (h.run_duration%100)) > (a.AvgDurationSeconds * (1.0 + (@PercentThreshold / 100.0)))
     AND ((h.run_duration/10000)*3600 + ((h.run_duration%10000)/100)*60 + (h.run_duration%100)) > (a.AvgDurationSeconds + (@MinutesThreshold * 60))
    )
);
