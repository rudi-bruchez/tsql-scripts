-----------------------------------------------------------------
-- Lists synonyms in the current database, avec base object names
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	name,
	base_object_name
FROM sys.synonyms
WHERE is_ms_shipped = 0
ORDER BY Name
OPTION (RECOMPILE, MAXDOP 1);