-------------------------------------------------------------------------------
-- essential information to get from a SQL Server when you open it 
-- for the first time
-- rudi@babaluga.com, go ahead license
-------------------------------------------------------------------------------

SELECT 'windows_release' as info, windows_release as value
FROM sys.dm_os_windows_info
UNION ALL
SELECT 'total_physical_memory_gb', total_physical_memory_kb / 1024 / 1024.0
FROM sys.dm_os_sys_memory
UNION ALL
SELECT 
	'NUMA_nodes', COUNT(DISTINCT parent_node_id)
FROM sys.dm_os_schedulers
WHERE status = 'VISIBLE ONLINE' AND is_online = 1
UNION ALL
SELECT 
	'CPUs', COUNT(*)
FROM sys.dm_os_schedulers
WHERE status = 'VISIBLE ONLINE' AND is_online = 1
UNION ALL
SELECT name, value
FROM sys.configurations
WHERE configuration_id = 1581
UNION ALL
SELECT name, value
FROM sys.configurations
WHERE configuration_id = 1544
UNION ALL
SELECT name, value
FROM sys.configurations
WHERE configuration_id = 1539
UNION ALL
SELECT name, value
FROM sys.configurations
WHERE configuration_id = 1538
UNION ALL
SELECT counter_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'page life expectancy'
AND object_name LIKE '%Buffer Manager%';