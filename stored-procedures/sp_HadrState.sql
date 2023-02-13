USE master;
GO

CREATE OR ALTER PROCEDURE sp_HadrState
AS BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT 
		CONCAT(g.name, '.', ar.replica_server_name, '.',DB_NAME(rs.database_id),
			CASE rs.is_primary_replica
				WHEN 1 THEN '.P'
				ELSE '.S'
			END,
			CASE rs.is_local
				WHEN 1 THEN ' (local)'
				ELSE ' (distant)'
			END
		) as db
	   ,CONCAT(rs.synchronization_state_desc, ' / ', rs.synchronization_health_desc) AS health
	   ,CONCAT(rs.database_state_desc COLLATE DATABASE_DEFAULT, IIF(rs.is_suspended = 0, '', 'suspended : ' + rs.suspend_reason_desc)) AS database_state
	   ,CAST(rs.last_sent_time AS TIME(3)) AS last_sent
	   ,CAST(rs.last_received_time AS TIME(3)) AS last_received
	   ,CAST(rs.last_hardened_time AS TIME(3)) AS last_hardened
	   ,CAST(rs.last_redone_time AS TIME(3)) AS last_redone
	   ,rs.log_send_queue_size as log_send_queue_size_kb
	   ,rs.log_send_rate AS [log_send_rate kb/s]
	   ,rs.redo_queue_size AS redo_queue_size_kb
	   ,rs.redo_rate AS [redo_rate kb/s]
	   ,CAST(rs.last_commit_time AS TIME(3)) AS last_commit
	   ,rs.secondary_lag_seconds
	FROM sys.dm_hadr_database_replica_states rs
	JOIN sys.availability_groups g ON rs.group_id = g.group_id
	JOIN sys.availability_replicas ar ON rs.replica_id = ar.replica_id
	ORDER BY [db]
	OPTION (RECOMPILE, MAXDOP 1);
END