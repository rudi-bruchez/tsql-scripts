-----------------------------------------------------------------
-- Generates code to drop all users in a database
-- Must be executed in the context of the database
--
-- Runs in listing mode by default: it prints the DROP USER
-- commands. Set @execute = 1 to run them.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

DECLARE @execute bit = 0;

DECLARE cur CURSOR FAST_FORWARD
FOR 
    SELECT name as username
    FROM sys.database_principals
    WHERE TYPE IN (
        'E', -- External user from Azure Active Directory
        'G', -- Windows group
        'S', -- SQL user
        'U', -- Windows user
        'X'  --External group from Azure Active Directory group or applications
    )
    AND sid > 0x01

DECLARE @username sysname
OPEN cur

FETCH NEXT FROM cur INTO @username
WHILE (@@fetch_status = 0)
BEGIN
    
	DECLARE @sql nvarchar(1000)
	SET @sql = CONCAT ('DROP USER IF EXISTS ', QUOTENAME(@username))
	PRINT @sql

    IF @execute = 1
    BEGIN
        BEGIN TRY
            EXEC (@sql)
        END TRY
        BEGIN CATCH
            -- it will not work if the user owns any object in the database ...
            PRINT CONCAT('Error dropping ', QUOTENAME(@username), ' : ', ERROR_MESSAGE())
        END CATCH
    END

	FETCH NEXT FROM cur INTO @username
END

CLOSE cur
DEALLOCATE cur

IF @execute = 0
	PRINT 'Listing mode: nothing dropped. Set @execute = 1 to run.';
GO
