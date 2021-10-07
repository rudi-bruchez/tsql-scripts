-------------------------------------------------------------------------------
-- basic info on SQLOS schedulers
-- rudi@babaluga.com, go ahead license
-------------------------------------------------------------------------------

SELECT 
	cpu_id,
	is_idle,
	current_tasks_count,
	runnable_tasks_count,
	current_workers_count,
	active_workers_count,
	work_queue_count,
	SUM(CAST(is_idle as tinyint)) OVER () as nb_idle,
	SUM(current_tasks_count) OVER () as nb_tasks,
	SUM(active_workers_count) OVER () as nb_workers,
	SUM(runnable_tasks_count) OVER () as nb_runnable
FROM sys.dm_os_schedulers
WHERE status = N'VISIBLE ONLINE'
OPTION (RECOMPILE, MAXDOP 1);