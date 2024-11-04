-----------------------------------------------------------------
-- fn_hadr_synchronization_lag
-- Returns the synchronization lag in seconds between the primary
-- and secondary replicas of an availability group
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

USE master;
-- USE _dba;
GO

CREATE OR ALTER FUNCTION dbo.fn_hadr_synchronization_lag
(
	@database_name sysname
)
RETURNS INT
AS BEGIN
	DECLARE @value INT;

	SELECT
		@value = DATEDIFF(second, last_redone_time, last_hardened_time)
	FROM sys.dm_hadr_database_replica_states
	WHERE is_primary_replica = 0
	AND DB_NAME(database_id) = @database_name

	RETURN @value;
END;