----------------------------
-- buffer cache hit ratio
----------------------------
SELECT 
	@@SERVERNAME AS [Server Name], 
	[object_name], 
	counter_name, 
	cntr_value AS [valeur],
	cntr_type
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE [object_name] LIKE N'%Buffer%' -- Handles named instances
AND counter_name IN (
	N'Page life expectancy', 
	N'Buffer cache hit ratio',
	N'Buffer cache hit ratio base'
)	
OPTION (RECOMPILE);
-- todo : 100 * 'Buffer Cache Hit Ratio' / 'Buffer Cache Hit Ratio base'
