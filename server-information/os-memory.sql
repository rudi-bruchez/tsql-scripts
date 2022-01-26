SELECT --*, 
	CAST(available_physical_memory_kb / 1024 / 1024.0 as DECIMAL(10, 2)) as 'available_physical_memory_gb',
	CAST(total_physical_memory_kb / 1024 / 1024.0 as DECIMAL(10, 2)) as 'total_physical_memory_gb'
FROM sys.dm_os_sys_memory WITH (READUNCOMMITTED)
OPTION (RECOMPILE, MAXDOP 1);