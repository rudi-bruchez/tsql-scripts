-----------------------------------------------------------------
-- fn_tableSize : returns the number of rows in a table
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

CREATE OR ALTER FUNCTION dbo.fn_tableSize
(
	@tableName SYSNAME
)
RETURNS TABLE
AS
	RETURN (
		SELECT 
			OBJECT_NAME(i.object_id) AS [table],
			SUM(p.rows) AS rows,
			FORMAT(SUM(p.rows), 'N0') AS RowsFormatted
		FROM sys.indexes i
		JOIN sys.partitions AS p 
			ON p.object_id = i.object_id 
			AND p.index_id = i.index_id
		WHERE i.object_id = OBJECT_ID(@tableName)
		AND i.index_id <= 1
		GROUP BY i.object_id
	)
