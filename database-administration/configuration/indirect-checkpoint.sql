-----------------------------------------------------------------
-- Switch databases still on automatic checkpoint
-- (TARGET_RECOVERY_TIME = 0) to indirect checkpoint.
--
-- Runs in listing mode by default: it prints what it would change.
-- Set @execute = 1 to apply.
--
-- Covers the user databases and model, so databases created later
-- inherit the setting. Databases that cannot be altered are skipped
-- and reported: not online, read-only, or a secondary replica of an
-- availability group (change it on the primary).
--
-- The change is online and needs no restart. To go back:
-- ALTER DATABASE [db] SET TARGET_RECOVERY_TIME = 0 SECONDS;
--
-- Automatic checkpoint walks the whole buffer pool to find the dirty
-- pages of a database. With 1 TB of memory or more, each walk takes
-- seconds and logs error 898 with command 'CHECKPOINT'. Indirect
-- checkpoint keeps a list of dirty pages per database instead.
-- Check the effect by counting error 898 in the error log before and after.
-- https://learn.microsoft.com/troubleshoot/sql/database-engine/performance/buffer-pool-scan-runs-slowly-large-memory-machines
-- https://techcommunity.microsoft.com/t5/sql-server-support/sql-server-large-ram-and-db-checkpointing/ba-p/318973
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;

DECLARE @execute bit = 0;
DECLARE @target_seconds int = 60;

DECLARE @name sysname, @reason nvarchar(100), @sql nvarchar(max);

DECLARE dbs CURSOR LOCAL FAST_FORWARD FOR
	SELECT d.name,
		CASE
			WHEN d.state <> 0 THEN N'skipped: ' + d.state_desc
			WHEN d.is_read_only = 1 THEN N'skipped: read-only'
			WHEN sys.fn_hadr_is_primary_replica(d.name) = 0 THEN N'skipped: AG secondary replica'
		END
	FROM sys.databases d
	WHERE (d.database_id > 4 OR d.name = N'model')
	AND d.target_recovery_time_in_seconds = 0
	ORDER BY d.name;

OPEN dbs;
FETCH NEXT FROM dbs INTO @name, @reason;

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @sql = CONCAT(N'ALTER DATABASE ', QUOTENAME(@name), N' SET TARGET_RECOVERY_TIME = ', @target_seconds, N' SECONDS;');

	IF @reason IS NOT NULL
		PRINT CONCAT(QUOTENAME(@name), N': ', @reason);
	ELSE IF @execute = 1
	BEGIN
		BEGIN TRY
			EXEC (@sql);
			PRINT CONCAT(QUOTENAME(@name), N': done');
		END TRY
		BEGIN CATCH
			PRINT CONCAT(QUOTENAME(@name), N': failed, ', ERROR_MESSAGE());
		END CATCH
	END
	ELSE
		PRINT @sql;

	FETCH NEXT FROM dbs INTO @name, @reason;
END

CLOSE dbs;
DEALLOCATE dbs;

IF @execute = 0
	PRINT 'Listing mode: nothing changed. Set @execute = 1 to apply.';

SELECT name, target_recovery_time_in_seconds, state_desc, is_read_only
FROM sys.databases
WHERE database_id > 4 OR name = N'model'
ORDER BY target_recovery_time_in_seconds, name;
