-----------------------------------------------------------------
-- Measure the secondary synchronization lag
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH AG_Stats AS (
  SELECT 
    ar.replica_server_name,
    DB_NAME(rs.database_id) AS [DBName],
    rs.last_commit_time,
	rs.is_primary_replica,
	CAST(rs.redo_queue_size / 1000.00 as numeric(10, 2)) as redo_queue_mb,
	CAST(rs.redo_rate / 1000.00 as numeric(10, 2)) as redo_rate_mb
  FROM sys.dm_hadr_database_replica_states rs
  JOIN sys.availability_replicas ar 
    ON rs.replica_id = ar.replica_id
)
SELECT 
  p.replica_server_name AS [primary_replica],
  p.[DBName] AS [DatabaseName], 
  s.replica_server_name AS [secondary_replica],
  DATEDIFF(SECOND, s.last_commit_time, p.last_commit_time) AS [Sync_Lag_Sec],
  s.redo_queue_mb,
  s.redo_rate_mb as [avg_redo_rate_mb/s],
  CAST(s.redo_queue_mb / s.redo_rate_mb / 60 as numeric(10, 2)) as theoretical_min_to_go
FROM AG_Stats p
JOIN AG_Stats s ON s.[DBName] = p.[DBName] 
WHERE p.is_primary_replica = 1
AND p.replica_server_name <> s.replica_server_name
ORDER BY [DatabaseName], [secondary_replica]
OPTION (RECOMPILE, MAXDOP 1);