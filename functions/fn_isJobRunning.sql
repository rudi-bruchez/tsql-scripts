-----------------------------------------------------------------
-- fn_isJobRunning
-- Returns 1 if the job is running, 0 otherwise
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

USE Master;
GO

CREATE OR ALTER FUNCTION dbo.fn_isJobRunning
(
    @job_name sysname
)
RETURNS BIT
AS BEGIN
    RETURN (
        SELECT CAST(COUNT(*) AS BIT)
        FROM msdb.dbo.sysjobactivity ja
        INNER JOIN msdb.dbo.sysjobs j
            ON j.job_id = ja.job_id
        WHERE
            j.name = @job_name
            AND ja.start_execution_date IS NOT NULL
            AND ja.stop_execution_date IS NULL
            AND ja.session_id = (SELECT MAX(session_id) FROM msdb.dbo.sysjobactivity)
    )
END;

