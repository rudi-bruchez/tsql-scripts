-----------------------------------------------------------------
-- change all TEXT columns of the current database's tables to
-- VARCHAR(MAX), keeping NULL / NOT NULL
--
-- Three result sets, to run in this order:
-- 1. ALTER COLUMN: metadata only, the values stay in LOB pages
-- 2. UPDATE t SET c = c: brings values under 8000 bytes back in row.
--    Fully logged, rewrites every row: maintenance window, and in
--    batches on a large table
-- 3. ALTER TABLE ... REBUILD: gives back the LOB pages emptied by 2.
--    A rebuild alone does not move the values in row
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
	CONCAT('ALTER TABLE ', QUOTENAME(c.TABLE_SCHEMA), '.', QUOTENAME(c.TABLE_NAME),
	       ' ALTER COLUMN ', QUOTENAME(c.COLUMN_NAME), ' VARCHAR(MAX) ',
	       CASE c.IS_NULLABLE WHEN 'YES' THEN 'NULL' ELSE 'NOT NULL' END, ';') as DDL
FROM INFORMATION_SCHEMA.COLUMNS AS c
JOIN INFORMATION_SCHEMA.TABLES  AS t
  ON t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
WHERE c.DATA_TYPE = 'text'
AND t.TABLE_TYPE = 'BASE TABLE'
OPTION (RECOMPILE, MAXDOP 1);

SELECT
	CONCAT('UPDATE ', QUOTENAME(c.TABLE_SCHEMA), '.', QUOTENAME(c.TABLE_NAME),
	       ' SET ', QUOTENAME(c.COLUMN_NAME), ' = ', QUOTENAME(c.COLUMN_NAME), ';') as DML
FROM INFORMATION_SCHEMA.COLUMNS AS c
JOIN INFORMATION_SCHEMA.TABLES  AS t
  ON t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
WHERE c.DATA_TYPE = 'text'
AND t.TABLE_TYPE = 'BASE TABLE'
OPTION (RECOMPILE, MAXDOP 1);

SELECT
	CONCAT('ALTER TABLE ', QUOTENAME(c.TABLE_SCHEMA), '.', QUOTENAME(c.TABLE_NAME), ' REBUILD;') as DDL
FROM INFORMATION_SCHEMA.COLUMNS AS c
JOIN INFORMATION_SCHEMA.TABLES  AS t
  ON t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
WHERE c.DATA_TYPE = 'text'
AND t.TABLE_TYPE = 'BASE TABLE'
GROUP BY c.TABLE_SCHEMA, c.TABLE_NAME
OPTION (RECOMPILE, MAXDOP 1);
