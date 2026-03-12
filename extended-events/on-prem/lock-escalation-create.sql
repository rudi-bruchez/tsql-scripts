-----------------------------------------------------------------
-- Lock Escalation Event Session
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

CREATE EVENT SESSION [lock_escalations] ON SERVER
-- ADD EVENT sqlserver.error_reported(
--     ACTION(sqlserver.sql_text)
--     WHERE ([severity]>(10))),
ADD EVENT sqlserver.lock_escalation(
    ACTION(
        sqlserver.client_app_name,
        sqlserver.database_name,
        sqlserver.session_id,
        sqlserver.sql_text)
    )
ADD TARGET package0.event_file(SET filename=N'LockEscalation',max_file_size=(100))
WITH (
    MAX_MEMORY=4096 KB,
    EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY=30 SECONDS,
    MAX_EVENT_SIZE=0 KB,
    MEMORY_PARTITION_MODE=NONE,
    TRACK_CAUSALITY=OFF,
    STARTUP_STATE=OFF)
GO

