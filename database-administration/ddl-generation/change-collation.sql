-----------------------------------------------------------------
-- Change collation for all columns in the database
--
-- Generates one ALTER COLUMN per character column of a base table,
-- keeping its declared length and nullability. Computed columns are
-- skipped. A column used by an index, a constraint, a computed column
-- or a schema-bound object must be freed first: its ALTER will fail.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @collation sysname = 'French_CI_AS';

SELECT CONCAT('ALTER TABLE ', QUOTENAME(c.TABLE_SCHEMA), '.' , QUOTENAME(c.TABLE_NAME),
		' ALTER COLUMN ', QUOTENAME(c.COLUMN_NAME), ' ',
		c.DATA_TYPE,
		CASE
			WHEN c.DATA_TYPE IN ('text', 'ntext') THEN ''
			WHEN c.CHARACTER_MAXIMUM_LENGTH = -1 THEN '(max)'
			ELSE CONCAT('(', c.CHARACTER_MAXIMUM_LENGTH, ')')
		END,
		' COLLATE ', @collation,
		CASE c.IS_NULLABLE WHEN 'NO' THEN ' NOT NULL' ELSE ' NULL' END)
FROM INFORMATION_SCHEMA.COLUMNS c
JOIN INFORMATION_SCHEMA.TABLES t ON t.TABLE_SCHEMA = c.TABLE_SCHEMA
	AND t.TABLE_NAME = c.TABLE_NAME
	AND t.TABLE_TYPE = 'BASE TABLE'
WHERE c.COLLATION_NAME IS NOT NULL
AND c.COLLATION_NAME <> @collation
AND COLUMNPROPERTY(OBJECT_ID(QUOTENAME(c.TABLE_SCHEMA) + '.' + QUOTENAME(c.TABLE_NAME)), c.COLUMN_NAME, 'IsComputed') = 0
OPTION (RECOMPILE, MAXDOP 1);
