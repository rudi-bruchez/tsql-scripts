-----------------------------------------------------------------
-- automatic seeding history
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT 
    DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), has.start_time) as start_time,
    DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), has.completion_time) as completion_time,
	DATEDIFF(second, has.start_time, has.completion_time) as duration_sec,
    ag.name,
    db.database_name,
    has.current_state,
    has.performed_seeding,
    has.failure_state,
    has.failure_state_desc,
	has.number_of_attempts
FROM sys.dm_hadr_automatic_seeding has 
JOIN sys.availability_databases_cluster db ON has.ag_db_id = db.group_database_id
JOIN sys.availability_groups ag ON has.ag_id = ag.group_id
OPTION (RECOMPILE, MAXDOP 1);

