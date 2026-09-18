-----------------------------------------------------------------
-- Rebuild heaps with forwarded records
--
-- Stored procedure version of
-- database-administration/maintenance/rebuild-heaps-forwarded-records.sql
-- Create it in master or in a DBA database, like Ola Hallengren's
-- maintenance solution, and call it from a SQL Agent job step:
--
--   EXEC dbo.RebuildHeaps @Databases = N'Sales, Stock', @Execute = 1;
--
-- For each database, finds the heaps (tables without clustered index)
-- with more than @MinForwarded forwarded records and rebuilds them
-- (ALTER TABLE ... REBUILD), worst first. The procedure ends with an
-- error if any rebuild failed, so the job fails and notifies.
--
-- Standard Edition: the rebuild is OFFLINE, the table is locked
-- (reads included) for the duration, and all its nonclustered indexes
-- are rebuilt too. Run it when activity is lowest.
--
-- SQL Server 2017+ (STRING_SPLIT, STRING_AGG)
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

CREATE OR ALTER PROCEDURE dbo.RebuildHeaps
    @Databases        nvarchar(max) = NULL,  -- comma separated list, NULL = all user databases
    @MinForwarded     bigint        = 10,    -- rebuild heaps with more forwarded records than this
    @TimeLimitMinutes int           = 240,   -- start no new rebuild after this (NULL = no limit)
    @LockTimeoutMs    int           = 60000, -- skip a table that can't be locked within this delay
    @Execute          bit           = 0      -- 0 = list only, 1 = rebuild
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start datetime2 = SYSDATETIME(), @t0 datetime2, @errors int = 0,
            @db sysname, @schema sysname, @table sysname, @pages bigint, @forwarded bigint,
            @n int, @sql nvarchar(max), @msg nvarchar(2048);

    DECLARE @dbs TABLE (id int IDENTITY PRIMARY KEY, name sysname NOT NULL);
    DECLARE @heaps TABLE (schema_name sysname, table_name sysname, pages bigint, forwarded bigint);

    -- ONLINE and writable only: skips offline, read-only and AG secondary databases
    IF @Databases IS NULL
        INSERT @dbs (name)
        SELECT name FROM sys.databases
        WHERE database_id > 4 AND state_desc = N'ONLINE' AND is_read_only = 0
        AND DATABASEPROPERTYEX(name, 'Updateability') = N'READ_WRITE'
        ORDER BY name;
    ELSE
    BEGIN
        INSERT @dbs (name)
        SELECT d.name FROM sys.databases d
        JOIN STRING_SPLIT(@Databases, N',') x ON d.name COLLATE DATABASE_DEFAULT = LTRIM(RTRIM(x.value))
        WHERE d.state_desc = N'ONLINE' AND d.is_read_only = 0
        AND DATABASEPROPERTYEX(d.name, 'Updateability') = N'READ_WRITE'
        ORDER BY d.name;

        -- a typo in the job step must not go unnoticed
        SELECT @msg = STRING_AGG(LTRIM(RTRIM(x.value)), N', ')
        FROM STRING_SPLIT(@Databases, N',') x
        WHERE LTRIM(RTRIM(x.value)) <> N''
        AND NOT EXISTS (SELECT * FROM @dbs d WHERE d.name COLLATE DATABASE_DEFAULT = LTRIM(RTRIM(x.value)));
        IF @msg IS NOT NULL
        BEGIN
            SET @errors += 1;
            SET @msg = CONCAT(N'Database(s) not found, offline or read-only: ', @msg);
            RAISERROR(N'%s', 0, 1, @msg) WITH NOWAIT;
        END;
    END;

    DECLARE dbs CURSOR LOCAL FAST_FORWARD FOR SELECT name FROM @dbs ORDER BY id;
    OPEN dbs;
    FETCH NEXT FROM dbs INTO @db;
    -- the time limit also stops the search in the next databases (DETAILED reads every heap page)
    WHILE @@FETCH_STATUS = 0
    AND (@Execute = 0 OR @TimeLimitMinutes IS NULL OR DATEDIFF(MINUTE, @start, SYSDATETIME()) < @TimeLimitMinutes)
    BEGIN
        DELETE @heaps;

        -- DETAILED is needed: forwarded_record_count is NULL in LIMITED mode
        -- i.index_id, not a literal 0: the DMV must never be called for a non-heap (error 2591)
        -- DETAILED takes an IS lock on each heap, so a locked heap would stall the search without LOCK_TIMEOUT
        SET @sql = CONCAT(N'SET LOCK_TIMEOUT ', @LockTimeoutMs, N';
            SELECT s.name, t.name, SUM(ps.page_count), SUM(ps.forwarded_record_count)
            FROM ', QUOTENAME(@db), N'.sys.tables t
            JOIN ', QUOTENAME(@db), N'.sys.schemas s ON s.schema_id = t.schema_id
            JOIN ', QUOTENAME(@db), N'.sys.indexes i ON i.object_id = t.object_id AND i.index_id = 0
            CROSS APPLY sys.dm_db_index_physical_stats(DB_ID(@db), i.object_id, i.index_id, NULL, N''DETAILED'') ps
            WHERE t.is_ms_shipped = 0
            AND ps.alloc_unit_type_desc = N''IN_ROW_DATA''
            GROUP BY s.name, t.name
            HAVING SUM(ps.forwarded_record_count) > @MinForwarded
            OPTION (MAXDOP 1);');

        BEGIN TRY
            INSERT @heaps (schema_name, table_name, pages, forwarded)
            EXEC sys.sp_executesql @sql, N'@db sysname, @MinForwarded bigint', @db, @MinForwarded;
            SET @n = @@ROWCOUNT;
            SET @msg = CONCAT(@db, N': ', @n, N' heap(s) with more than ', @MinForwarded, N' forwarded records');
        END TRY
        BEGIN CATCH
            SET @errors += 1;
            SET @msg = CONCAT(@db, N': ERROR ', ERROR_NUMBER(), N' while searching heaps: ', ERROR_MESSAGE());
        END CATCH;
        RAISERROR(N'%s', 0, 1, @msg) WITH NOWAIT;

        DECLARE heaps CURSOR LOCAL FAST_FORWARD FOR
            SELECT schema_name, table_name, pages, forwarded FROM @heaps ORDER BY forwarded DESC;
        OPEN heaps;
        FETCH NEXT FROM heaps INTO @schema, @table, @pages, @forwarded;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- SET LOCK_TIMEOUT takes no variable, so it goes in the dynamic batch
            SET @sql = CONCAT(N'SET LOCK_TIMEOUT ', @LockTimeoutMs, N'; ALTER TABLE ',
                              QUOTENAME(@db), N'.', QUOTENAME(@schema), N'.', QUOTENAME(@table), N' REBUILD;');
            SET @msg = CONCAT(@db, N'.', @schema, N'.', @table, N': ', @forwarded, N' forwarded records, ', @pages, N' pages');

            IF @Execute = 0
                RAISERROR(N'%s -> %s', 0, 1, @msg, @sql) WITH NOWAIT;
            ELSE IF DATEDIFF(MINUTE, @start, SYSDATETIME()) >= @TimeLimitMinutes
            BEGIN
                SET @msg = CONCAT(N'Time limit of ', @TimeLimitMinutes, N' minutes reached, remaining heaps left for next run.');
                RAISERROR(N'%s', 0, 1, @msg) WITH NOWAIT;
                BREAK;
            END
            ELSE
            BEGIN
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

            FETCH NEXT FROM heaps INTO @schema, @table, @pages, @forwarded;
        END;
        CLOSE heaps;
        DEALLOCATE heaps;

        FETCH NEXT FROM dbs INTO @db;
    END;
    IF @@FETCH_STATUS = 0
    BEGIN
        SET @msg = CONCAT(N'Time limit of ', @TimeLimitMinutes, N' minutes reached, databases from ', @db, N' on left for next run.');
        RAISERROR(N'%s', 0, 1, @msg) WITH NOWAIT;
    END;
    CLOSE dbs;
    DEALLOCATE dbs;

    IF @errors > 0
        RAISERROR(N'%d error(s) during heap rebuild, see messages above.', 16, 1, @errors);
END;
