-----------------------------------------------------------------
-- Audit SELECT permissions on a database object
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @table_name sysname = N'MyTable';

;WITH rolemembers AS (
	SELECT 
	    r.name AS rolename,   
	    COALESCE(u.name, 'No members') AS username   
	FROM sys.database_role_members AS rm  
	RIGHT JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id  
	LEFT JOIN sys.database_principals u ON rm.member_principal_id = u.principal_id  
	WHERE r.type = 'R'
)
SELECT pr.principal_id
    --,pr.name
    ,COALESCE(rm.username, pr.name) as username
    --,pr.type_desc
    ,pe.state_desc
    ,pe.permission_name
    ,CONCAT(s.name, '.', o.name) AS ObjectName
FROM sys.database_principals pr
JOIN sys.database_permissions pe ON pe.grantee_principal_id = pr.principal_id
JOIN sys.objects o ON pe.major_id = o.object_id
JOIN sys.schemas s ON o.schema_id = s.schema_id
LEFT JOIN rolemembers rm ON rm.rolename = pr.name AND pr.type_desc = N'DATABASE_ROLE'
WHERE pe.permission_name = N'SELECT'
AND pe.state_desc = N'GRANT'
AND s.name = 'dbo'
AND o.name = @table_name

UNION

SELECT pr.principal_id
    ,COALESCE(rm.username, pr.name) as username
    --,pr.type_desc
    ,pe.state_desc
    ,pe.permission_name
    --,s.name AS SchemaName
    ,CONCAT(s.name, '.', @table_name) AS ObjectName
FROM sys.database_principals pr
JOIN sys.database_permissions pe ON pe.grantee_principal_id = pr.principal_id
JOIN sys.schemas s ON pe.major_id = s.schema_id
LEFT JOIN rolemembers rm ON rm.rolename = pr.name AND pr.type_desc = N'DATABASE_ROLE'
WHERE pe.permission_name = N'SELECT'
AND pe.state_desc = N'GRANT'
AND s.name = 'dbo'

UNION

SELECT u.principal_id
    ,rm.username as username
    --,pr.type_desc
    ,'GRANT'
    ,'SELECT'
    ,CONCAT('dbo.', @table_name) AS ObjectName
FROM sys.database_principals u
JOIN rolemembers rm ON rm.username = u.name
WHERE rm.rolename = N'db_datareader'

ORDER BY username
OPTION (RECOMPILE, MAXDOP 1);