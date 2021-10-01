SELECT *, 
	available_physical_memory_kb / 1024 / 1024.0 as 'available_physical_memory_gb',
	total_physical_memory_kb / 1024 / 1024.0 as 'total_physical_memory_gb'
FROM sys.dm_os_sys_memory WITH (READUNCOMMITTED)
OPTION (RECOMPILE);