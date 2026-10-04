-----------------------------------------------------------------
-- Convert all LOB columns of a table (text, ntext, image) to
-- varchar(max), nvarchar(max), varbinary(max).
--
-- @Execute = 0 (default) prints the statements, 1 runs them.
-- NULL / NOT NULL is kept: ALTER COLUMN without it makes the column
-- nullable.
--
-- The ALTER only changes metadata: the existing values stay in LOB
-- pages. @MoveInRow = 1 adds UPDATE t SET c = c, which brings values
-- under 8000 bytes back in row. It is fully logged and rewrites every
-- row: run it in a maintenance window, in batches on a large table.
--
-- EXEC dbo.ConvertLobToMax @schema_name = N'dbo', @table_name = N'Orders';
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

CREATE OR ALTER PROCEDURE dbo.ConvertLobToMax
    @schema_name sysname,
    @table_name sysname,
    @Execute bit = 0,
    @MoveInRow bit = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql NVARCHAR(MAX);

    DECLARE cur CURSOR LOCAL FAST_FORWARD
    FOR
        SELECT c.name,
               t.name,
               c.is_nullable
        FROM sys.columns AS c
        JOIN sys.types   AS t ON t.user_type_id = c.user_type_id
        WHERE c.object_id = OBJECT_ID(QUOTENAME(@schema_name) + N'.' + QUOTENAME(@table_name))
        AND t.name IN (N'text', N'ntext', N'image')
        ORDER BY c.column_id;

    DECLARE
        @column_name sysname,
        @data_type sysname,
        @is_nullable bit;

    OPEN cur

    FETCH NEXT FROM cur INTO @column_name, @data_type, @is_nullable
    WHILE (@@fetch_status = 0)
    BEGIN
        DECLARE @type NVARCHAR(100) =
            CASE @data_type
                WHEN N'text' THEN N'VARCHAR(MAX)'
                WHEN N'ntext' THEN N'NVARCHAR(MAX)'
                WHEN N'image' THEN N'VARBINARY(MAX)'
            END;

        SET @sql = CONCAT(N'ALTER TABLE ', QUOTENAME(@schema_name), N'.', QUOTENAME(@table_name),
            N' ALTER COLUMN ', QUOTENAME(@column_name), N' ', @type,
            IIF(@is_nullable = 1, N' NULL', N' NOT NULL'), N';');

        IF @MoveInRow = 1
            SET @sql = CONCAT(@sql, CHAR(13), CHAR(10),
                N'UPDATE ', QUOTENAME(@schema_name), N'.', QUOTENAME(@table_name),
                N' SET ', QUOTENAME(@column_name), N' = ', QUOTENAME(@column_name), N';');

        IF @Execute = 1
            EXEC sys.sp_executesql @sql;
        ELSE
            PRINT @sql;

        FETCH NEXT FROM cur INTO @column_name, @data_type, @is_nullable
    END

    CLOSE cur
    DEALLOCATE cur

END;
GO
