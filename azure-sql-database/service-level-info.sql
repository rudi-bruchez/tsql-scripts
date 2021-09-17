-- CPU
SELECT *
FROM sys.dm_os_schedulers dos
WHERE dos.status = N'VISIBLE ONLINE'
OPTION (RECOMPILE, MAXDOP 1);

SELECT dopc.counter_name
	  ,dopc.cntr_value
FROM sys.dm_os_performance_counters dopc
WHERE dopc.object_name LIKE '%Memory Manager%'
AND TRIM(dopc.counter_name) IN (
N'Database Cache Memory (KB)',
N'Target Server Memory (KB)',
N'Total Server Memory (KB)',
N'Maximum Workspace Memory (KB)'
)
OPTION (RECOMPILE, MAXDOP 1);
