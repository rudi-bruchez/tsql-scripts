-----------------------------------------------------------------
-- Analyzes varchar max length and actual max length
-- BEWARE - slow on large tables
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @schema sysname = 'dbo';
DECLARE @table  sysname = '<TABLE NAME';

SET NOCOUNT ON;

DECLARE @t TABLE (
	col sysname not null,
	maxlen int not null
)

DECLARE cur CURSOR
FAST_FORWARD
FOR 
	SELECT COLUMN_NAME
	FROM INFORMATION_SCHEMA.COLUMNS c
	WHERE TABLE_SCHEMA = @schema
	AND TABLE_NAME = @table
	AND c.DATA_TYPE = 'varchar';

DECLARE @col sysname
OPEN cur

FETCH NEXT FROM cur INTO @col
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN

		DECLARE @sql varchar(max) = 
		CONCAT('SELECT ''', @col, ''' as col, MAX(LEN(', QUOTENAME(@col), ')) as maxlen
			FROM ', QUOTENAME(@schema), '.', QUOTENAME(@table), ' WITH (READUNCOMMITTED)', '')
		
		INSERT INTO @t
		EXEC (@sql)
	END
	FETCH NEXT FROM cur INTO @col
END

CLOSE cur
DEALLOCATE cur

SELECT 
	c.name,
	c.column_id,
	c.max_length,
	CONCAT('(', IIF(c.max_length < 0, 'MAX', CAST(c.max_length as varchar(20))), ')') as [length],
	c.precision,
	c.scale,
	c.is_nullable,
	c.is_computed,
	c.is_sparse,
	ty.name as [type],
	ty.max_length,
	t.maxlen as max_length_in_table
FROM sys.columns c
JOIN sys.types ty ON c.system_type_id = ty.system_type_id
JOIN @t t ON c.name = t.col
WHERE c.object_id =  OBJECT_ID(CONCAT(QUOTENAME(@schema), '.', QUOTENAME(@table)))
OPTION (RECOMPILE, MAXDOP 1);

