-----------------------------------------------------------------
-- Convert all LOB columns in a table to varXXX(max)
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

CREATE OR ALTER PROCEDURE dbo.ConvertLobToMax
    @schema_name sysname,
    @table_name sysname
AS 
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql NVARCHAR(MAX);

    DECLARE cur CURSOR
    FAST_FORWARD
    FOR 
        SELECT COLUMN_NAME, DATA_TYPE
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = @schema_name
        AND TABLE_NAME = @table_name
        AND DATA_TYPE IN (N'text', N'ntext', N'image');

    DECLARE 
        @column_name sysname,
        @data_type sysname;

    OPEN cur

    FETCH NEXT FROM cur INTO @column_name, @data_type
    WHILE (@@fetch_status = 0)
    BEGIN
        DECLARE @type NVARCHAR(100) =
            CASE @data_type
                WHEN N'text' THEN N'VARCHAR(MAX)'
                WHEN N'ntext' THEN N'NVARCHAR(MAX)'
                WHEN N'image' THEN N'VARBINARY(MAX)'
            END;

        SET @sql = CONCAT('ALTER TABLE ', QUOTENAME(@schema_name), 
            '.', QUOTENAME(@table_name), 
        ' ALTER COLUMN ', QUOTENAME(@column_name), ' ', @type , ';');

        EXEC (@sql);

        FETCH NEXT FROM cur INTO @column_name, @data_type
    END

    CLOSE cur
    DEALLOCATE cur

END;
GO

