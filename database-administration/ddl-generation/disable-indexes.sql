-----------------------------------------------------------------
-- Code to generate disable and enable index commands for 
-- SQL Server, to integrate into some import procedure
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

DECLARE @tables AS TABLE (
    name SYSNAME NOT NULL PRIMARY KEY
)

INSERT INTO @tables
VALUES ('table_1');

SELECT 'ALTER INDEX [' + name + '] ON [' + OBJECT_NAME(object_id) + '] DISABLE;'
FROM sys.indexes i
WHERE i.type_desc = N'NONCLUSTERED'
AND OBJECT_NAME(object_id) IN (SELECT name FROM @tables)
ORDER BY OBJECT_NAME(object_id), name
OPTION (RECOMPILE, MAXDOP 1);

SELECT 'ALTER INDEX [' + name + '] ON [' + OBJECT_NAME(object_id) + '] REBUILD WITH (SORT_IN_TEMPDB = ON);'
FROM sys.indexes i
WHERE i.type_desc = N'NONCLUSTERED'
AND OBJECT_NAME(object_id) IN (SELECT name FROM @tables)
ORDER BY OBJECT_NAME(object_id), name
OPTION (RECOMPILE, MAXDOP 1);