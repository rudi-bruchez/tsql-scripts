
----------------------------------------------------------------------------------------------------------
-- 1. Monitoring using XEvents
-- Borrowed from David Barbarin, slightly modified
-- https://blog.dbi-services.com/sql-server-2016-alwayson-direct-seeding-and-performance-considerations/
----------------------------------------------------------------------------------------------------------
CREATE EVENT SESSION [hadr_direct_seeding] 
ON SERVER 
ADD EVENT sqlserver.hadr_automatic_seeding_start ( 
    ACTION(sqlserver.database_name,sqlserver.sql_text)) ,
ADD EVENT sqlserver.hadr_automatic_seeding_state_transition (
    ACTION(sqlserver.database_name,sqlserver.sql_text)),
ADD EVENT sqlserver.hadr_automatic_seeding_success ( 
    ACTION(sqlserver.database_name,sqlserver.sql_text)),
ADD EVENT sqlserver.hadr_automatic_seeding_timeout (
    ACTION(sqlserver.database_name,sqlserver.sql_text)),
ADD EVENT sqlserver.hadr_physical_seeding_progress (
    ACTION(sqlserver.database_name,sqlserver.sql_text))
ADD TARGET package0.event_file
(
    SET filename = N'hadr_direct_seeding',
    max_file_size = (2048), 
    max_rollover_files = (10))
WITH
(
    MAX_MEMORY=4096 KB,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 30 SECONDS,
    MAX_EVENT_SIZE = 0 KB,
    MEMORY_PARTITION_MODE = NONE,
    TRACK_CAUSALITY = OFF,
    STARTUP_STATE = OFF
)
GO

----------------------------------------------------------------------------------------------------------
-- 2. Monitoring using DMV
----------------------------------------------------------------------------------------------------------

SELECT 
    DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), has.start_time) as start_time,
    DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), has.completion_time) as completion_time,
	DATEDIFF(second, has.start_time, has.completion_time) as duration_sec,
    ag.name,
    db.database_name,
    has.current_state,
    has.performed_seeding,
    has.failure_state,
    has.failure_state_desc,
	has.number_of_attempts
FROM sys.dm_hadr_automatic_seeding has 
JOIN sys.availability_databases_cluster db ON has.ag_db_id = db.group_database_id
JOIN sys.availability_groups ag ON has.ag_id = ag.group_id;


SELECT 
    ag.name,
	pss.local_database_name AS local_database, 
    pss.role_desc as [role], 
    pss.internal_state_desc AS internal_state, 
    CAST(pss.transfer_rate_bytes_per_second / 1024.0 / 1024 AS DECIMAL(10, 2)) AS transfer_rate_MB_second, 
    CAST(pss.transferred_size_bytes / 1024.0 / 1024 AS DECIMAL(10, 2)) AS transferred_size_MB, 
    CAST(pss.database_size_bytes / 1024.0 / 1024 AS DECIMAL(10, 2)) AS database_size_MB, 
    DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), pss.start_time_utc) as start_time,
    DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), pss.end_time_utc) as end_time,
    DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), pss.estimate_time_complete_utc) as estimate_time_complete, 
    pss.total_disk_io_wait_time_ms, 
    pss.total_network_wait_time_ms, 
    pss.is_compression_enabled 
FROM sys.dm_hadr_physical_seeding_stats pss
JOIN sys.dm_hadr_automatic_seeding has ON pss.local_physical_seeding_id = has.operation_id
JOIN sys.availability_groups ag ON has.ag_id = ag.group_id;
