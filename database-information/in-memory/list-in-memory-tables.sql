-----------------------------------------------------------------
-- Lists In-Memory tables and types in the current database.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
	CONCAT(QUOTENAME(SCHEMA_NAME(t.schema_id)), '.',
		QUOTENAME(t.name)) as [name],
	'table' as [type],
	t.durability_desc as [durability],
	t.create_date
FROM sys.tables t
WHERE t.is_memory_optimized = 1
UNION ALL
SELECT
	CONCAT(QUOTENAME(SCHEMA_NAME(tt.schema_id)), '.',
		QUOTENAME(tt.name)) as [name],
	'UDT' as [type],
	NULL as [durability],
	NULL as create_date
FROM sys.table_types tt
WHERE is_memory_optimized = 1
ORDER BY [name]
OPTION (RECOMPILE, MAXDOP 1);