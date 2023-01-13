-----------------------------------------------------------------
-- Check the log file for errors
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT cl.*, e.severity, e.text
FROM _dba.dbo.CommandLog cl
LEFT JOIN sys.messages e ON cl.ErrorNumber = e.message_id AND e.language_id = 1033
WHERE cl.StartTime > DATEADD(day, -1, CURRENT_TIMESTAMP)
AND ErrorNumber <> 0
ORDER BY StartTime
OPTION (RECOMPILE, MAXDOP 1);