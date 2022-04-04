-----------------------------------------------------------------
-- searches columns in tables, by their name.
-- and generate sql to inspect column content.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @column_name sysname = '%PROFIL%';

SELECT 
	c.TABLE_SCHEMA, 
	c.TABLE_NAME, 
	c.COLUMN_NAME, 
	CONCAT(
		'SELECT TOP 100 ', QUOTENAME(c.COLUMN_NAME), ', COUNT(*) as cnt, MAX(DATALENGTH(', QUOTENAME(c.COLUMN_NAME), 
		')) FROM ', QUOTENAME(c.TABLE_SCHEMA), '.', QUOTENAME(c.TABLE_NAME), ' WITH (READUNCOMMITTED) ',
		'GROUP BY ', QUOTENAME(c.COLUMN_NAME), ' ORDER BY cnt DESC;'
	) as [sql]
FROM INFORMATION_SCHEMA.COLUMNS c
JOIN INFORMATION_SCHEMA.TABLES t ON c.TABLE_SCHEMA = c.TABLE_SCHEMA AND c.TABLE_NAME = t.TABLE_NAME
WHERE c.COLUMN_NAME LIKE @column_name
AND t.TABLE_TYPE = 'BASE TABLE'
OPTION (RECOMPILE, MAXDOP 1);
