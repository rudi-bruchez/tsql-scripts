-----------------------------------------------------------------
-- Informations on REDO operations on the secondary.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	ag.name as ag,
	DB_NAME(database_id) as db,
	CAST(redo_queue_size / 1024.00 as decimal(20, 2)) as redo_queue_size_mb, -- as long as the redo queue size is > 0, no log backup can be taken.
	/*
		Msg 35295, Level 16, State 1, Line 9
		Log backup for database "xxx" on a secondary replica failed because the last backup LSN (0x00014e11:00003821:0001) 
		from the primary database is greater than the current local redo LSN (0x00014de4:00048108:003f). 
		No log records need to be backed up at this time. Retry the log-backup operation later. 
		Msg 3013, Level 16, State 1, Line 9
		BACKUP LOG is terminating abnormally.
	*/
	drs.synchronization_state_desc,
	drs.synchronization_health_desc,
	drs.is_suspended,
	drs.suspend_reason_desc,
	drs.last_redone_time,
	DATEDIFF(second, drs.last_redone_time, CURRENT_TIMESTAMP) as last_redone_delay_seconds
FROM sys.dm_hadr_database_replica_states drs
JOIN sys.availability_groups ag ON drs.group_id = ag.group_id
OPTION (RECOMPILE, MAXDOP 1);