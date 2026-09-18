-----------------------------------------------------------------
-- rebuild heaps with forwarded records
--
-- Finds heaps (tables without clustered index) in the CURRENT database
-- with more than @MinForwarded forwarded records and rebuilds them
-- (ALTER TABLE ... REBUILD), worst first.
--
-- Meant for a weekend SQL Agent job step: set the step's Database to
-- the target database, and an output file in Advanced to keep
-- the per-table log. The job fails at the end if any table failed.
--
-- Standard Edition: the rebuild is OFFLINE, the table is locked
-- (reads included) for the duration, and all its nonclustered indexes
-- are rebuilt too. Run it when activity is lowest.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
SET NOCOUNT ON;

DECLARE @MinForwarded     bigint = 10;    -- rebuild heaps with more forwarded records than this
DECLARE @Execute          bit    = 1;     -- 0 = list only, 1 = rebuild
DECLARE @TimeLimitMinutes int    = 240;   -- start no new rebuild after this (NULL = no limit)
DECLARE @LockTimeoutMs    int    = 60000; -- skip a table that can't be locked within this delay

DECLARE @start datetime2 = SYSDATETIME(), @t0 datetime2, @errors int = 0,
        @i int = 1, @n int, @sql nvarchar(max), @msg nvarchar(2048);

DECLARE @heaps TABLE (id int IDENTITY PRIMARY KEY, schema_name sysname, table_name sysname,
                      pages bigint, forwarded bigint);

-- DETAILED is needed: forwarded_record_count is NULL in LIMITED mode
INSERT @heaps (schema_name, table_name, pages, forwarded)
SELECT s.name, t.name, SUM(ps.page_count), SUM(ps.forwarded_record_count)
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
JOIN sys.indexes i ON i.object_id = t.object_id AND i.index_id = 0
-- i.index_id, not a literal 0: the DMV must never be called for a non-heap (error 2591)
CROSS APPLY sys.dm_db_index_physical_stats(DB_ID(), i.object_id, i.index_id, NULL, N'DETAILED') ps
WHERE t.is_ms_shipped = 0
AND ps.alloc_unit_type_desc = N'IN_ROW_DATA'
GROUP BY s.name, t.name
HAVING SUM(ps.forwarded_record_count) > @MinForwarded
ORDER BY SUM(ps.forwarded_record_count) DESC
OPTION (MAXDOP 1);

SET @n = @@ROWCOUNT;
SET @msg = CONCAT(DB_NAME(), N': ', @n, N' heap(s) with more than ', @MinForwarded, N' forwarded records');
RAISERROR(N'%s', 0, 1, @msg) WITH NOWAIT;

WHILE @i <= @n
BEGIN
    -- SET LOCK_TIMEOUT takes no variable, so it goes in the dynamic batch
    SELECT @sql = CONCAT(N'SET LOCK_TIMEOUT ', @LockTimeoutMs, N'; ALTER TABLE ',
                         QUOTENAME(schema_name), N'.', QUOTENAME(table_name), N' REBUILD;'),
           @msg = CONCAT(schema_name, N'.', table_name, N': ', forwarded, N' forwarded records, ', pages, N' pages')
    FROM @heaps WHERE id = @i;
    SET @i += 1;

    IF @Execute = 0
    BEGIN
        RAISERROR(N'%s -> %s', 0, 1, @msg, @sql) WITH NOWAIT;
        CONTINUE;
    END;

    IF DATEDIFF(MINUTE, @start, SYSDATETIME()) >= @TimeLimitMinutes
    BEGIN
        SET @msg = CONCAT(N'Time limit of ', @TimeLimitMinutes, N' minutes reached, ', @n - @i + 2, N' heap(s) left for next run.');
        RAISERROR(N'%s', 0, 1, @msg) WITH NOWAIT;
        BREAK;
    END;

    SET @t0 = SYSDATETIME();
    BEGIN TRY
        EXEC (@sql);
        SET @msg += CONCAT(N' -> rebuilt in ', DATEDIFF(SECOND, @t0, SYSDATETIME()), N' s');
    END TRY
    BEGIN CATCH
        SET @errors += 1;
        SET @msg += CONCAT(N' -> ERROR ', ERROR_NUMBER(), N': ', ERROR_MESSAGE());
    END CATCH;
    RAISERROR(N'%s', 0, 1, @msg) WITH NOWAIT;
END;

IF @errors > 0
    RAISERROR(N'%d heap rebuild(s) failed, see messages above.', 16, 1, @errors);
