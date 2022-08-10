-----------------------------------------------------------------
-- availability groupes metadata
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	g.name,
	g.failure_condition_level,
	g.health_check_timeout,
	g.automated_backup_preference_desc as [automated_backup_preference],
	gs.primary_recovery_health_desc as [primary_health],
	gs.primary_replica,
	gs.secondary_recovery_health_desc as [secondary_health],
	gs.synchronization_health_desc as [synchronization_health]
FROM sys.availability_groups g
JOIN sys.dm_hadr_availability_group_states gs ON g.group_id = gs.group_id
OPTION (RECOMPILE, MAXDOP 1);