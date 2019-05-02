-----------------------------------------------------------------
-- queries important performance counters 
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT 
	@@SERVERNAME AS [Server Name], 
	RTRIM([object_name]) as [object_name], 
	RTRIM(counter_name) as counter_name, 
	cntr_value AS [valeur]
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE 
	([object_name] LIKE N'%Buffer Manager%' -- Handle named instances
	AND counter_name IN (
		N'Page life expectancy', 
		N'Buffer cache hit ratio',
		N'Buffer cache hit ratio base'
	)
	)
	OR ([object_name] LIKE N'%Plan Cache%' AND instance_name = N'_Total' AND counter_name = N'Cache Object Counts')
OPTION (RECOMPILE);
-- todo : 100 * 'Buffer Cache Hit Ratio' / 'Buffer Cache Hit Ratio base'
