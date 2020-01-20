SELECT *, 
	1.0 * signal_wait_time_ms / waiting_tasks_count as avg_signal
FROM sys.dm_db_wait_stats
ORDER BY wait_time_ms DESC;