-----------------------------------------------------------------
-- List members of the SQL Agent roles in msdb
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE msdb;
GO

SELECT r.name as [role], u.name as [user]
FROM sys.database_principals u
JOIN sys.database_role_members rm ON u.principal_id = rm.member_principal_id
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
WHERE r.name LIKE 'SQLAgent%'
ORDER BY [user], [role]
OPTION (RECOMPILE, MAXDOP 1);