-- from SSMS
SELECT
	s.event_session_id AS [Id],
	s.name AS [Name],
	CASE WHEN (running.create_time IS NULL) THEN 0 ELSE 1 END AS [IsRunning],
	s.event_retention_mode AS [EventRetentionMode],
	s.max_dispatch_latency AS [MaxDispatchLatency],
	s.max_memory AS [MaxMemory],
	s.max_event_size AS [MaxEventSize],
	s.memory_partition_mode AS [MemoryPartitionMode],
	s.track_causality AS [TrackCausality],
	s.startup_state AS [AutoStart],
	running.create_time AS [StartTime]
FROM sys.server_event_sessions s
LEFT JOIN sys.dm_xe_sessions AS running ON running.name = s.name
ORDER BY s.name;