-----------------------------------------------------------------
-- generate code to change the fill factor for index where it has
-- been set to anything else than 0 or 100
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

DECLARE @online bit = 1;
DECLARE @sort_in_tempdb bit = 1;

SELECT OBJECT_SCHEMA_NAME(object_id) + '.' + OBJECT_NAME(object_id) AS [table]
	  ,name AS [index]
	  ,type_desc AS [type]
	  ,fill_factor
	  ,is_padded as [padindex]
	  ,CONCAT('ALTER INDEX [' , name , '] ON [' , OBJECT_SCHEMA_NAME(object_id) , '].[' 
        , OBJECT_NAME(object_id) , '] REBUILD WITH (FILLFACTOR = 100'
		, IIF(@online = 1, ', ONLINE = ON', '')
		, IIF(@sort_in_tempdb = 1, ', SORT_IN_TEMPDB = ON', ''), ')'
		) AS [DDL]
FROM sys.indexes
WHERE fill_factor BETWEEN 1 AND 99
ORDER BY [table], [index]
OPTION (RECOMPILE, MAXDOP 1);