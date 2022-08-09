-----------------------------------------------------------------
-- AlwaysOn database replica states
-- Rudi Bruchez - rudi@babaluga.com - 2020.07.02 - version 01
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	g.name as AG
   ,ar.replica_server_name as [Replica]
   ,DB_NAME(rs.database_id) AS [db]
   ,rs.is_local
   ,rs.is_primary_replica
   ,CONCAT(rs.synchronization_state_desc, ' (', rs.synchronization_state, ')') AS synchronization_state
   ,CONCAT(rs.synchronization_health_desc, ' (', rs.synchronization_health, ')') AS synchronization_health
   ,CONCAT(rs.database_state_desc, ' (', rs.database_state, ')') AS database_state
   ,CONCAT(rs.is_suspended, IIF(rs.is_suspended = 0, '', CONCAT(rs.suspend_reason_desc, ' (', rs.suspend_reason, ')'))) AS is_suspended
   --,rs.recovery_lsn
   --,rs.truncation_lsn
   --,rs.last_sent_lsn
   ,CAST(rs.last_sent_time AS TIME(3)) AS last_sent
   --,rs.last_received_lsn
   ,CAST(rs.last_received_time AS TIME(3)) AS last_received
   --,rs.last_hardened_lsn
   ,CAST(rs.last_hardened_time AS TIME(3)) AS last_hardened
   --,rs.last_redone_lsn
   ,CAST(rs.last_redone_time AS TIME(3)) AS last_redone
   ,rs.log_send_queue_size
   ,rs.log_send_rate
   ,rs.redo_queue_size
   ,rs.redo_rate
   --,rs.filestream_send_rate
   --,rs.end_of_log_lsn
   --,rs.last_commit_lsn
   ,CAST(rs.last_commit_time AS TIME(3)) AS last_commit
   ,rs.low_water_mark_for_ghosts
   ,rs.secondary_lag_seconds
FROM sys.dm_hadr_database_replica_states rs
JOIN sys.availability_groups g ON rs.group_id = g.group_id
JOIN sys.availability_replicas ar ON rs.replica_id = ar.replica_id
OPTION (RECOMPILE, MAXDOP 1);
