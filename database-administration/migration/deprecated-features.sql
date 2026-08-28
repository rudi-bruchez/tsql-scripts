-----------------------------------------------------------------
-- Get deprecated features from perf counter
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
	TRIM(instance_name) as [feature],
	cntr_value
FROM sys.dm_os_performance_counters
WHERE
Object_name = N'SQLServer:Deprecated Features'
AND cntr_value > 0
ORDER BY [feature]
OPTION (RECOMPILE, MAXDOP 1);