-----------------------------------------------------------------
-- monitor physical seeding stats on principal
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT 
    ag.name as [AG],
	pss.local_database_name AS local_database, 
    pss.role_desc as [role], 
    pss.internal_state_desc AS internal_state, 
    CAST(pss.transfer_rate_bytes_per_second / 1024.0 / 1024 AS DECIMAL(10, 2)) AS transfer_rate_MB_second, 
    CAST(pss.transferred_size_bytes / 1024.0 / 1024 AS DECIMAL(10, 2)) AS transferred_size_MB, 
    CAST(pss.database_size_bytes / 1024.0 / 1024 AS DECIMAL(10, 2)) AS database_size_MB, 
    CAST(1.0 * pss.transferred_size_bytes / pss.database_size_bytes * 100 as numeric(5, 2)) as [%],
    DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), pss.start_time_utc) as start_time,
    DATEDIFF(mi, pss.start_time_utc, COALESCE(pss.end_time_utc, GETUTCDATE())) as minutes_elapsed,
    DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), pss.end_time_utc) as end_time,
    DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), pss.estimate_time_complete_utc) as estimate_time_complete, 
    pss.total_disk_io_wait_time_ms, 
    pss.total_disk_io_wait_time_ms / 1000 / 60 as io_waits_minutes, 
    pss.total_network_wait_time_ms, 
    pss.is_compression_enabled 
FROM sys.dm_hadr_physical_seeding_stats pss
JOIN sys.dm_hadr_automatic_seeding has ON pss.local_physical_seeding_id = has.operation_id
JOIN sys.availability_groups ag ON has.ag_id = ag.group_id
OPTION (RECOMPILE, MAXDOP 1);