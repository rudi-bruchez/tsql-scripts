SELECT 
	SUM(
	((CAST(mf.size as bigint) * 8192) / 1024 / 1024) -
	(((mf.size * CONVERT(FLOAT, 8) - CAST(FILEPROPERTY(mf.name, 'SpaceUsed') AS FLOAT) * CONVERT(FLOAT, 8)))
/ 1024)) / 1024 AS 'taille utilisée GB'
FROM sys.master_files mf
JOIN sys.databases db ON mf.database_id = db.database_id
WHERE DB_NAME(mf.database_id) = '<DATABASE NAME>'
AND mf.type_desc = 'ROWS';

