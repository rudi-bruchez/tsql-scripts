-----------------------------------------------------------------
-- Removes secondary files
-- You need to play with the WHERE clause :
--	  AND fg.is_default = 0
--	  AND df.name NOT LIKE '%-1'
-- to select specific files for your system
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @debug bit = 0

DECLARE cur CURSOR FAST_FORWARD
FOR 
	SELECT 
		fg.name as fg,
		df.name as [file],
		df.physical_name
	FROM [sys].[filegroups] fg
	JOIN [sys].[database_files] df ON fg.[data_space_id] = df.[data_space_id]
	WHERE fg.type = 'FG'
	AND fg.is_default = 0
	AND df.name NOT LIKE '%-1'
	AND df.type = 0 -- ROWS
	ORDER BY df.name


DECLARE @fg sysname, @file sysname, @physical_name nvarchar(4000)

OPEN cur

FETCH NEXT FROM cur INTO @fg, @file, @physical_name

WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		DECLARE @msg nvarchar(4000) = CONCAT('trying to remove file ', @file, ' (', @physical_name, ')');
		RAISERROR (@msg, 0, 0) WITH NOWAIT 
		
		DECLARE @sql nvarchar(max)
		
		SET @sql = CONCAT('DBCC SHRINKFILE (N''', @file, ''' , EMPTYFILE)');
		IF @debug = 1 PRINT @sql ELSE EXEC (@sql)

		SET @sql = CONCAT('ALTER DATABASE ', QUOTENAME(DB_NAME()), ' REMOVE FILE ', QUOTENAME(@file), ';');
		IF @debug = 1 PRINT @sql ELSE EXEC (@sql)

	END
	FETCH NEXT FROM cur INTO @fg, @file, @physical_name
END

CLOSE cur
DEALLOCATE cur
GO
