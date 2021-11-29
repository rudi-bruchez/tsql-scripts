-----------------------------------------------------------------
-- used space in the current database
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT 
	SUM(
	((CAST(mf.size as bigint) * 8192) / 1024 / 1024) -
	(((mf.size * CONVERT(FLOAT, 8) - CAST(FILEPROPERTY(mf.name, 'SpaceUsed') AS FLOAT) * CONVERT(FLOAT, 8)))
/ 1024)) / 1024 AS 'spaced used GB'
FROM sys.master_files mf
JOIN sys.databases db ON mf.database_id = db.database_id
WHERE mf.database_id = DB_ID()
AND mf.type_desc = 'ROWS';