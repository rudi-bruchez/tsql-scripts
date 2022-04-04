-----------------------------------------------------------------
-- find how many NULLs are in nullable columns in a table
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

DECLARE @schema sysname = N'dbo';
DECLARE @table  sysname = N'contact';

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

DECLARE @t AS TABLE (
	col sysname,
	nulls bigint,
	cnt bigint
);

DECLARE cur CURSOR FORWARD_ONLY
FOR 
	SELECT 
		CONCAT(QUOTENAME(c.TABLE_SCHEMA), '.', QUOTENAME(c.TABLE_NAME)) as tbl, 
		QUOTENAME(c.COLUMN_NAME) as col
	FROM INFORMATION_SCHEMA.COLUMNS c
	JOIN INFORMATION_SCHEMA.TABLES t ON c.TABLE_SCHEMA = c.TABLE_SCHEMA AND c.TABLE_NAME = t.TABLE_NAME
	WHERE t.TABLE_SCHEMA = @schema 
	AND t.TABLE_NAME = @table
	AND t.TABLE_TYPE = 'BASE TABLE'
	AND c.IS_NULLABLE = 'YES'
	ORDER BY c.ORDINAL_POSITION;

DECLARE @tbl nvarchar(257), @col sysname;
OPEN cur;

FETCH NEXT FROM cur INTO @tbl, @col;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		RAISERROR('processing column %s', 0, 0, @col) WITH NOWAIT;
		DECLARE @sql nvarchar(4000);
		SET @sql = CONCAT('SELECT ''', @col, ''', SUM(CASE WHEN ', @col, ' IS NULL THEN 1 ELSE 0 END) as nulls, COUNT(*) as cnt', ' FROM ', @tbl, ' WITH (READUNCOMMITTED);');
		--PRINT @sql
		INSERT INTO @t EXEC (@sql);
	END
	FETCH NEXT FROM cur INTO @tbl, @col;
END

CLOSE cur;
DEALLOCATE cur;

SELECT *
FROM @t;