
----------------------------------------------------------------------------------------------------------
-- 1. Monitoring using XEvents
-- Borrowed from David Barbarin, slightly modified
-- https://blog.dbi-services.com/sql-server-2016-alwayson-direct-seeding-and-performance-considerations/
----------------------------------------------------------------------------------------------------------
CREATE EVENT SESSION [hadr_automatic_seeding] 
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
    SET filename = N'hadr_automatic_seeding',
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