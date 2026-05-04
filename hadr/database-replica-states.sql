-----------------------------------------------------------------
-- AlwaysOn database replica states
-- Rudi Bruchez - rudi@babaluga.com 
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	g.name as AG
   ,ar.replica_server_name as [Replica]
   ,dbcs.database_name AS [db]
   ,IIF(rs.is_local = 1, 'Y', 'N') as [local]   
   ,IIF(dbcs.is_failover_ready = 1, 'Y', 'N') AS [FailoverReady]
   ,IIF(dbcs.is_database_joined = 1, 'Y', 'N') AS [Joined]
   ,IIF(rs.is_primary_replica = 1, 'Y', 'N') as [primary]
   ,CONCAT(rs.synchronization_state_desc, ' (', rs.synchronization_state, ')') AS synchronization_state
   ,CONCAT(rs.synchronization_health_desc, ' (', rs.synchronization_health, ')') AS synchronization_health
   ,CONCAT(rs.database_state_desc, ' (', rs.database_state, ')') AS database_state
   ,CONCAT(IIF(rs.is_suspended = 1, 'Y', 'N'), IIF(rs.is_suspended = 0, '', CONCAT(rs.suspend_reason_desc, ' (', rs.suspend_reason, ')'))) AS suspended
   ,DATEDIFF(minute, rs.last_sent_time, CURRENT_TIMESTAMP) AS last_sent_min
   ,DATEDIFF(minute, rs.last_received_time, CURRENT_TIMESTAMP) AS last_received_min
   ,DATEDIFF(minute, rs.last_hardened_time, CURRENT_TIMESTAMP) AS last_hardened_min
   ,DATEDIFF(minute, rs.last_redone_time, CURRENT_TIMESTAMP) AS last_redone_min
   ,DATEDIFF(minute, rs.last_commit_time, CURRENT_TIMESTAMP) AS last_commit_min
   ,DATEDIFF(minute, rs.last_redone_time, rs.last_hardened_time) as redo_latency_min
   ,ISNULL(CAST(rs.log_send_queue_size / 1024.0 as decimal(38, 2)), 0) AS [LogSendQueueSize_Mb]
   ,ISNULL(CAST(rs.log_send_rate / 1024.0 as decimal(38, 2)), -1) AS [LogSendRate_Mb]
   ,ISNULL(CAST(rs.redo_queue_size / 1024.0 as decimal(38, 2)), -1) AS [RedoQueueSize_Mb]
   ,ISNULL(CAST(rs.redo_rate / 1024.0 as decimal(38, 2)), -1) AS [RedoRate_Mb]
   ,rs.secondary_lag_seconds
   ,ISNULL(CASE 
    WHEN rs.is_primary_replica = 1 
        OR rs.redo_queue_size is null  
        OR rs.redo_queue_size = 0
        OR rs.redo_rate is null or rs.redo_rate = 0 THEN 0 
    ELSE CAST(CAST(rs.redo_queue_size AS DECIMAL(38, 2)) / rs.redo_rate / 60 AS DECIMAL(38, 2)) END, 0) AS [EstimatedRecoveryTime_Min]
FROM sys.dm_hadr_database_replica_states rs
JOIN sys.availability_groups g ON rs.group_id = g.group_id
JOIN sys.availability_replicas ar ON rs.replica_id = ar.replica_id
JOIN sys.dm_hadr_database_replica_cluster_states dbcs ON dbcs.replica_id = ar.replica_id
OPTION (RECOMPILE, MAXDOP 1);
