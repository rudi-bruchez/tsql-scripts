-- lists logins and server roles membership
SELECT 
	sp.principal_id,
	sp.name,
	sp.type_desc as [type],
	sp.create_date,
	sp.default_database_name as default_db,
	sp.default_language_name as language,
	(
		SELECT STRING_AGG(r.name, ', ')
		FROM sys.server_role_members rm
		JOIN sys.server_principals r ON rm.role_principal_id = r.principal_id
		WHERE rm.member_principal_id = sp.principal_id
	 ) as server_roles,
	 lt.session_nb,
	 lt.last_login
FROM sys.server_principals sp
LEFT JOIN (
	SELECT 
		login_name,
		count(*) as session_nb,
		cast(max(login_time) as datetime2(0)) as last_login
	FROM sys.dm_exec_sessions
	GROUP BY login_name
) lt ON sp.name = lt.login_name
WHERE sp.type IN ('S', 'U')
AND sp.principal_id > 1
AND sp.name NOT LIKE N'##%'
AND sp.name NOT LIKE N'NT SERVICE\%'
ORDER BY sp.name;

-- lists users and database roles membership
SELECT 
	p.principal_id,
	MIN(p.name) as [user],
	STRING_AGG(r.name, ', ') as db_roles
FROM sys.database_principals p
JOIN sys.database_role_members rm ON p.principal_id = rm.member_principal_id
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
GROUP BY p.principal_id
ORDER BY [user];

-- lists database permissions
;WITH cte AS (
	SELECT 
		p.principal_id, 
		p.name, 
		dp.permission_name as perm, 
		dp.state_desc as [state],
		CASE dp.class 
			WHEN 0 /* database */ THEN 'database'
			WHEN 1 /* object_or_column */ THEN (SELECT name FROM sys.objects WHERE object_id = dp.major_id)
			WHEN 3 /* schema */ THEN (SELECT CONCAT('SCHEMA::', name) FROM sys.schemas WHERE schema_id = dp.major_id)
		END as obj
	FROM sys.database_principals p
	JOIN sys.database_permissions dp 
		ON p.principal_id = dp.grantee_principal_id
	WHERE p.principal_id > 2
	/*
	p.principal_id
	0 -- public
	1 -- dbo
	2 -- guest
	*/
	AND dp.type NOT IN ('CO') -- Connect, not very interesting
)
SELECT 
	principal_id, name, state, obj,
	STRING_AGG(perm, ', ') as perms
FROM cte
GROUP BY principal_id, name, state, obj
ORDER BY name, obj;
