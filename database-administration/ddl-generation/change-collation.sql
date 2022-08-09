-----------------------------------------------------------------
-- Change collation for all columns in the database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @collation sysname = 'French_CI_AS';

SELECT CONCAT('ALTER TABLE ', QUOTENAME(TABLE_SCHEMA), '.' , QUOTENAME(TABLE_NAME), 
		' ALTER COLUMN ', QUOTENAME(COLUMN_NAME), ' ',
		DATA_TYPE, '(', CHARACTER_OCTET_LENGTH, ')', ' COLLATE ', @collation) 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLLATION_NAME IS NOT NULL
AND COLLATION_NAME <> @collation
OPTION (RECOMPILE, MAXDOP 1);