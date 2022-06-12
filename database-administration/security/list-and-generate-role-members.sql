-----------------------------------------------------------------
-- lists and generate DDL for database role members in the
-- current database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	r.name, 
	u.name,
	CONCAT('ALTER ROLE ', QUOTENAME(r.name), ' ADD MEMBER ', QUOTENAME(u.name), ';') as DDL
FROM sys.database_role_members rm
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals u ON rm.member_principal_id = u.principal_id
WHERE r.principal_id NOT IN (0)
AND r.is_fixed_role = 0
ORDER BY r.name, u.name
OPTION (RECOMPILE, MAXDOP 1);