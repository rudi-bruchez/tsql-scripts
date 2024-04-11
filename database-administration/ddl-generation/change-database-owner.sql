-----------------------------------------------------------------
-- generate code to change database owner to sa on all database
-- where it is not yet the case.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	name as db, 
	SUSER_SNAME(owner_sid) as [owner],
	CONCAT('ALTER AUTHORIZATION ON DATABASE::', QUOTENAME(name), ' TO [sa];') as ddl,
	CONCAT('ALTER AUTHORIZATION ON DATABASE::', QUOTENAME(name), ' TO ', QUOTENAME(SUSER_SNAME(owner_sid)) , ';') as ddl_back
FROM sys.databases
WHERE database_id > 4
AND owner_sid <> 0x01
--AND SUSER_SNAME(owner_sid) IS NULL
ORDER BY db
OPTION (RECOMPILE, MAXDOP 1);
