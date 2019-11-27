-----------------------------------------------------------------
-- generate code to change the fill factor for index where it has
-- been set to anything else than 0 or 100
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT OBJECT_SCHEMA_NAME(object_id) + '.' + OBJECT_NAME(object_id) AS [table]
	  ,name AS [index]
	  ,type_desc AS [type]
	  ,'ALTER INDEX [' + name + '] ON [' +OBJECT_SCHEMA_NAME(object_id) + '].[' 
        + OBJECT_NAME(object_id) + '] REBUILD WITH (FILLFACTOR = 100)' AS [DDL]
FROM sys.indexes
WHERE fill_factor BETWEEN 1 AND 99
ORDER BY [table], [index];