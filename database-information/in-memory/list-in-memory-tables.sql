-----------------------------------------------------------------
-- Lists In-Memory tables in the current directory.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	CONCAT(SCHEMA_NAME(QUOTENAME(t.schema_id)), '.',
		QUOTENAME(t.name)) as [table],
	t.durability_desc as [durability],
	t.create_date
FROM sys.tables t
WHERE t.is_memory_optimized = 1
ORDER BY [table]
OPTION (RECOMPILE, MAXDOP 1);