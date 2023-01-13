-----------------------------------------------------------------
-- Generates code to drop all users in a database
-- Must be executed in the context of the database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

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

    BEGIN TRY
        EXEC (@SQL) 
    END TRY
    BEGIN CATCH
        -- it will not work if the user owns any object in the database ...
        PRINT CONCAT('Error dropping ', QUOTENAME(@username), ' : ', ERROR_MESSAGE())
    END CATCH

	FETCH NEXT FROM cur INTO @username
END

CLOSE cur
DEALLOCATE cur
GO
