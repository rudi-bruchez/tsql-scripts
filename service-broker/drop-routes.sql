-----------------------------------------------------------------
-- Drop all Service Broker routes in the current database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;

Use [<database name>] -- CHANGE HERE THE NAME OF THE DATABASE

DECLARE @route VARCHAR(MAX)
DECLARE @sql NVARCHAR(MAX)

DECLARE cur CURSOR
FOR 
    SELECT name 
    FROM sys.routes 
    WHERE name NOT LIKE 'AutoCreatedLocal'

OPEN cur
FETCH NEXT FROM cur INTO @route
WHILE @@fetch_status = 0
BEGIN
    SET @sql= CONCAT('DROP ROUTE ', QUOTENAME(@route), ';');
    
    PRINT @sql;
    EXEC (@sql);

    FETCH NEXT FROM cur INTO @route
END

CLOSE cur
DEALLOCATE cur