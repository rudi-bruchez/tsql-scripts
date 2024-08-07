-----------------------------------------------------------------
-- Get primary keys for all tables
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	tc.CONSTRAINT_SCHEMA, 
	MIN(tc.TABLE_NAME) AS TABLE_NAME,
	tc.CONSTRAINT_NAME, 
	STRING_AGG(kcu.COLUMN_NAME, ', ') WITHIN GROUP (ORDER BY kcu.ORDINAL_POSITION) AS [Columns]
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_SCHEMA = kcu.CONSTRAINT_SCHEMA
	AND tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.CONSTRAINT_TYPE = N'PRIMARY KEY'
GROUP BY tc.CONSTRAINT_SCHEMA, tc.CONSTRAINT_NAME
ORDER BY tc.CONSTRAINT_SCHEMA, 
	TABLE_NAME
OPTION (RECOMPILE, MAXDOP 1);