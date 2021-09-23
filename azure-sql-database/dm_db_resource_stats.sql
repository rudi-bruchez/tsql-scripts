
SELECT
	end_time
   ,dtu_limit
   ,cpu_limit
   ,avg_cpu_percent
   ,avg_memory_usage_percent
   ,avg_data_io_percent
   ,avg_log_write_percent
   ,xtp_storage_percent
   ,max_worker_percent
   ,max_session_percent
   ,avg_login_rate_percent
   ,avg_instance_cpu_percent
   ,avg_instance_memory_percent
FROM sys.dm_db_resource_stats WITH (NOLOCK)
ORDER BY end_time DESC
OPTION (RECOMPILE);