SELECT 
	db,
	[Data File(s) Size (KB)] as [Data Size (MB)], 
	[Log File(s) Size (KB)] as [Log Size (MB)], 
	[Log File(s) Used Size (KB)] as [Log Used (MB)]
FROM (
	SELECT 
		instance_name as db,
		counter_name as [counter],
		CAST(cntr_value / 1000.0 as DECIMAL(18, 2)) as [value]
	FROM sys.dm_os_performance_counters pc
	WHERE pc.object_name LIKE '%:Databases%'
	AND counter_name IN ('Data File(s) Size (KB)', 'Log File(s) Size (KB)', 'Log File(s) Used Size (KB)')
	AND instance_name NOT IN ('_Total')
) as t
PIVOT (
	SUM([value])
	FOR [counter] IN ([Data File(s) Size (KB)], [Log File(s) Size (KB)], [Log File(s) Used Size (KB)])
) AS pt
ORDER BY db
OPTION (RECOMPILE);


--SELECT DISTINCT counter_name
--FROM sys.dm_os_performance_counters pc
--WHERE pc.object_name LIKE '%:Databases%'

