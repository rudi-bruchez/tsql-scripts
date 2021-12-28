-----------------------------------------------------------------
-- monitor physical seeding stats on secondary
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT 
	pss.remote_machine_name,
	pss.local_database_name AS local_database, 
    pss.role_desc as [role], 
    pss.internal_state_desc AS internal_state, 
    CAST(pss.transfer_rate_bytes_per_second / 1024.0 / 1024 AS DECIMAL(10, 2)) AS transfer_rate_MB_second, 
    CAST(pss.transferred_size_bytes / 1024.0 / 1024 / 1024 AS DECIMAL(10, 2)) AS transferred_size_GB, 
    CAST(pss.database_size_bytes / 1024.0 / 1024 / 1024 AS DECIMAL(10, 2)) AS database_size_GB, 
    DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), pss.start_time_utc) as start_time,
    pss.total_disk_io_wait_time_ms, 
    pss.total_network_wait_time_ms
FROM sys.dm_hadr_physical_seeding_stats pss
OPTION (RECOMPILE, MAXDOP 1);