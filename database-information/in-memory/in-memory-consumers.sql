-----------------------------------------------------------------
-- In-Memory OLTP memory consumers in the current database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- In-Memory OLTP memory consumers in the current database
SELECT CONVERT(CHAR(10), OBJECT_NAME(object_id)) AS Name,
    memory_consumer_type_desc,
    memory_consumer_desc,
    object_id,
    index_id,
    allocated_bytes,
    used_bytes
FROM sys.dm_db_xtp_memory_consumers
OPTION (RECOMPILE, MAXDOP 1);

-- In-Memory OLTP total memory allocated and used in the current database
SELECT SUM(allocated_bytes) / (1024 * 1024) AS total_allocated_MB,
    SUM(used_bytes) / (1024 * 1024) AS total_used_MB
FROM sys.dm_db_xtp_memory_consumers
OPTION (RECOMPILE, MAXDOP 1);
