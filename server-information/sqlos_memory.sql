SELECT
	CAST(virtual_address_space_reserved_kb / 1024.0 / 1024 as numeric(10, 2)) as [reserved_gb],
	CAST(virtual_address_space_committed_kb / 1024.0 / 1024 as numeric(10, 2)) as [committed_gb],
	*
FROM sys.dm_os_process_memory
OPTION (RECOMPILE, MAXDOP 1);