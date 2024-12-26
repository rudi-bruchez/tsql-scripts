-----------------------------------------------------------------
-- Mesaure secondary latency
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	g.name as AG
   ,ar.replica_server_name as [Replica]
   ,DB_NAME(rs.database_id) AS [db]
   ,rs.is_local
   ,CONCAT(rs.is_suspended, IIF(rs.is_suspended = 0, '', CONCAT(rs.suspend_reason_desc, ' (', rs.suspend_reason, ')'))) AS is_suspended
   ,CAST(rs.last_sent_time AS TIME(3)) AS last_sent
   ,CAST(rs.last_hardened_time AS TIME(3)) AS last_hardened
   ,CAST(rs.last_redone_time AS TIME(3)) AS last_redone
   ,rs.log_send_queue_size
   ,DATEDIFF(minute, rs.last_redone_time, rs.last_hardened_time) as redo_latency_minutes
   ,rs.log_send_rate
   ,rs.redo_queue_size
   ,rs.redo_rate
   ,rs.secondary_lag_seconds
FROM sys.dm_hadr_database_replica_states rs
JOIN sys.availability_groups g ON rs.group_id = g.group_id
JOIN sys.availability_replicas ar ON rs.replica_id = ar.replica_id
WHERE rs.is_primary_replica = 0
OPTION (RECOMPILE, MAXDOP 1);
