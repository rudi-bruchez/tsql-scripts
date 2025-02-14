-----------------------------------------------------------------
-- queries important performance counters 
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT N'Buffer cache hit ratio' AS counter_name, 
CAST(CAST((ratio.cntr_value * 1.0 / base.cntr_value) * 100.0 AS NUMERIC(5, 2)) as NVARCHAR(100)) as [Value]
FROM sys.dm_os_performance_counters ratio
JOIN sys.dm_os_performance_counters base 
	ON ratio.object_name = base.object_name
WHERE RTRIM(ratio.object_name) LIKE N'%:Buffer Manager'
AND ratio.counter_name = N'Buffer cache hit ratio'
AND base.counter_name = N'Buffer cache hit ratio base'
UNION ALL
SELECT CONCAT(TRIM([counter_name]), ' per NUMA') as counter_name, 
	STRING_AGG(CONCAT('NUMA ', TRIM([instance_name]), ' : ', [cntr_value]), ',') as [Value]
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%SQLServer:Buffer Node%'
AND [counter_name] = 'Page life expectancy'
GROUP BY [counter_name]
UNION ALL 
SELECT 
	RTRIM(counter_name) as counter_name, 
	CAST(cntr_value as NVARCHAR(100)) AS [value]
FROM sys.dm_os_performance_counters WITH (READUNCOMMITTED)
WHERE (RTRIM([object_name]) LIKE N'%:Buffer Manager' -- Handle named instances
	AND counter_name IN (N'Page life expectancy'))
OR (RTRIM([object_name]) LIKE N'%:Plan Cache' AND instance_name = N'_Total' AND counter_name = N'Cache Object Counts')
OPTION (RECOMPILE, MAXDOP 1);