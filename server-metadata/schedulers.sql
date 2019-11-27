-------------------------------------------------------------------------------
-- basic info on SQLOS schedulers
-- rudi@babaluga.com, go ahead license
-------------------------------------------------------------------------------

SELECT 
	cpu_id,
	is_idle,
	current_tasks_count,
	current_workers_count,
	runnable_tasks_count,
	work_queue_count,
	pending_disk_io_count,
	load_factor,
	total_cpu_idle_capped_ms
FROM sys.dm_os_schedulers
WHERE status = 'VISIBLE ONLINE';