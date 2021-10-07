-- sql server uptime
SELECT 
	sqlserver_start_time,
	DATEDIFF(day, sqlserver_start_time, CURRENT_TIMESTAMP) as uptime_days, 
	DATEDIFF(hour, sqlserver_start_time, CURRENT_TIMESTAMP) as uptime_hours
FROM sys.dm_os_sys_info;