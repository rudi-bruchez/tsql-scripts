-----------------------------------------------------------------
-- List all tables in a database ordered by the number of columns 
-- starting with the highest number, and show nullable columns 
-- count, rowcount and if the table if compressed.

-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

;WITH cte_partitions AS (
    SELECT p.object_id,
        SUM(p.rows) as rows,
        IIF(SUM(p.data_compression) > 0, 1, 0) as compressed
    FROM sys.partitions p
    GROUP BY p.object_id
)
SELECT 
	t.object_id, 
	CONCAT(QUOTENAME(SCHEMA_NAME(MIN(t.schema_id))), '.', QUOTENAME(MIN(t.name))) as [table], 
	COUNT(*) as [nb_cols],
	SUM(IIF(c.is_nullable = 1, 1, 0)) as [nb_nullables],
	--,STRING_AGG(IIF(c.is_nullable = 1, c.name, NULL), ', ')
	MIN(p.rows) as rows,
	MIN(p.compressed) as compressed
FROM sys.tables t
JOIN sys.columns c ON t.object_id = c.object_id
JOIN cte_partitions p ON t.object_id = p.object_id
WHERE t.type = 'U'
GROUP BY t.object_id
ORDER BY [nb_nullables] DESC, [table]
OPTION (RECOMPILE, MAXDOP 1);