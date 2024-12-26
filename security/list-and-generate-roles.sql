-----------------------------------------------------------------
-- Lists roles in the current database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	name,
	create_date,
	CONCAT('CREATE ROLE ', QUOTENAME(name), ';') as DDL
FROM sys.database_principals
WHERE type = 'R'
AND principal_id NOT IN (0)
AND is_fixed_role = 0
ORDER BY name
OPTION (RECOMPILE, MAXDOP 1);