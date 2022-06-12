-----------------------------------------------------------------
-- Lists logins in the current instance
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @withPassword bit = 1;

SELECT 
	p.name,
	p.principal_id,
	p.sid,
	p.type_desc as [type],
	CAST(p.create_date as datetime2(0)) as create_date,
	CAST(p.modify_date as datetime2(0)) as modify_date,
	p.default_language_name as [default_language],
	p.default_database_name as [default_database],
	l.password_hash,
	CONCAT('CREATE LOGIN ', QUOTENAME(p.name),
		CASE p.type
			WHEN 'U' THEN ' FROM WINDOWS WITH '
			WHEN 'S' THEN IIF(@withPassword = 1, CONCAT(' WITH PASSWORD = ', 
                CONVERT(varchar(max), l.password_hash, 1), ' HASHED,'), '') 
                + CONCAT(' CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF, SID = ', 
                CONVERT(varchar(max), p.sid, 1), ', ')
		END, 'DEFAULT_DATABASE = ', QUOTENAME(p.default_database_name), 
            ', DEFAULT_LANGUAGE = ', p.default_language_name 
	) as DDL
FROM sys.server_principals p
LEFT JOIN sys.sql_logins l ON p.principal_id = l.principal_id
WHERE p.type IN ('U', 'S')
AND p.sid NOT IN (0x01)
AND p.is_disabled = 0
AND p.name NOT LIKE 'NT SERVICE\%'
AND p.name NOT IN ('NT AUTHORITY\SYSTEM')
ORDER BY p.name
OPTION (RECOMPILE, MAXDOP 1);