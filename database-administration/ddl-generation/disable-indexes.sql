-----------------------------------------------------------------
-- Code to generate disable and enable index commands for 
-- SQL Server, to integrate into some import procedure
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT 'ALTER INDEX [' + name + '] ON [' + OBJECT_NAME(object_id) + '] DISABLE;'
FROM sys.indexes i
WHERE i.type_desc = N'NONCLUSTERED'
AND OBJECT_NAME(object_id) IN ('TABLE_1', 'TABLE_2')
ORDER BY OBJECT_NAME(object_id), name

SELECT 'ALTER INDEX [' + name + '] ON [' + OBJECT_NAME(object_id) + '] REBUILD WITH (SORT_IN_TEMPDB = ON);'
FROM sys.indexes i
WHERE i.type_desc = N'NONCLUSTERED'
AND OBJECT_NAME(object_id) IN ('TABLE_1', 'TABLE_2')
ORDER BY OBJECT_NAME(object_id), name;