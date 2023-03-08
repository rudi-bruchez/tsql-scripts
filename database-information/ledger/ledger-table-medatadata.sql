-----------------------------------------------------------------
-- ledger tables medatadata in SQL Server 2022
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	CONCAT(QUOTENAME(SCHEMA_NAME(t.schema_id)) + '.', QUOTENAME(t.name)) as [table],
	CONCAT(QUOTENAME(SCHEMA_NAME(th.schema_id)) + '.', QUOTENAME(th.name)) as [history_table],
	CONCAT(QUOTENAME(SCHEMA_NAME(lv.schema_id)) + '.', QUOTENAME(lv.name)) as [ledger_view],
	t.ledger_type_desc AS [ledger_type]
FROM sys.tables t
LEFT JOIN sys.tables th ON t.history_table_id = th.object_id
LEFT JOIN sys.views lv ON t.ledger_view_id = lv.object_id
WHERE t.ledger_type IN (2, 3)
ORDER BY [table]
OPTION (RECOMPILE, MAXDOP 1);