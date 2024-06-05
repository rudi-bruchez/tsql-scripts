-----------------------------------------------------------------
-- list inlineable and non inlineable scalar UDF
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT m.object_id
	  ,CONCAT(QUOTENAME(SCHEMA_NAME(o.schema_id)), '.'
		, QUOTENAME(o.name)) AS [name]
	  ,m.inline_type
	  ,m.is_inlineable
FROM sys.sql_modules AS m     
JOIN sys.objects AS o ON m.object_id = o.object_id  
WHERE o.type_desc = N'SQL_SCALAR_FUNCTION'
AND o.is_ms_shipped = 0
OPTION (RECOMPILE, MAXDOP 1);
