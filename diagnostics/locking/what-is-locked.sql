-----------------------------------------------------------------
-- adapted from https://stackoverflow.com/questions/7820907/how-to-find-out-what-table-a-page-lock-belongs-to
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

SELECT dm_tran_locks.request_session_id,
       dm_tran_locks.resource_database_id,
       DB_NAME(dm_tran_locks.resource_database_id) AS dbname,
       CASE
           WHEN resource_type = 'OBJECT'
               THEN OBJECT_NAME(dm_tran_locks.resource_associated_entity_id)
           ELSE OBJECT_NAME(partitions.OBJECT_ID)
       END AS ObjectName,
       partitions.index_id,
       indexes.name AS index_name,
       dm_tran_locks.resource_type,
       dm_tran_locks.resource_description,
       dm_tran_locks.resource_associated_entity_id,
       dm_tran_locks.request_mode,
       dm_tran_locks.request_status
FROM sys.dm_tran_locks
LEFT JOIN sys.partitions ON partitions.hobt_id = dm_tran_locks.resource_associated_entity_id
LEFT JOIN sys.indexes ON indexes.OBJECT_ID = partitions.OBJECT_ID AND indexes.index_id = partitions.index_id
WHERE resource_associated_entity_id > 0
  AND resource_database_id = DB_ID()
ORDER BY request_session_id, resource_associated_entity_id 
OPTION (RECOMPILE, MAXDOP 1);