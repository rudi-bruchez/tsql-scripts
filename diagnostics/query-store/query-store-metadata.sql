-----------------------------------------------------------------
-- Query Store Metadata
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    DB_NAME() as [db],
    desired_state_desc as desired_state,
    actual_state_desc as actual_state,
    CASE readonly_reason
            WHEN 0 THEN ''
            WHEN 1 THEN 'db is in read-only'
            WHEN 2 THEN 'db is in single-user'
            WHEN 4 THEN 'db is in emergency mode'
            WHEN 8 THEN 'db is secondary replica'
            WHEN 65536 THEN 'Query Store reached the size limit'
            WHEN 131072 THEN 'The number of different statements in Query Store reached the internal memory limit'
            WHEN 262144 THEN 'Size of in-memory items waiting to be persisted on disk reached the internal memory limit'
            WHEN 524288 THEN 'Database reached disk size limit'
            ELSE CAST(readonly_reason as varchar(50))
    END as readonly_reason,
    query_capture_mode_desc as query_capture_mode,
    current_storage_size_mb,
    max_storage_size_mb
FROM sys.database_query_store_options
OPTION (RECOMPILE, MAXDOP 1);