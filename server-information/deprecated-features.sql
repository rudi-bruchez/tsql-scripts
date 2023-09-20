-----------------------------------------------------------------
-- Using the deprecated features performance counters
-- to identify deprecated features' usage.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	instance_name,
	cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name = 'SQLServer:Deprecated Features'
AND cntr_value > 0
ORDER BY instance_name
OPTION (RECOMPILE, MAXDOP 1);