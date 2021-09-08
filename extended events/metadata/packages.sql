SELECT
	guid,
	name,
	description
FROM sys.dm_xe_packages
WHERE
	(capabilities & 1 = 0 
	OR capabilities IS NULL)
ORDER BY name