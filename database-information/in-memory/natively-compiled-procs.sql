-----------------------------------------------------------------
-- Lists natively-compiled procedures
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT CONCAT(QUOTENAME(OBJECT_SCHEMA_NAME(m.object_id)),
	'.', QUOTENAME(OBJECT_NAME(m.object_id))) as [proc]
FROM sys.sql_modules m
WHERE m.uses_native_compilation = 1
OPTION (RECOMPILE, MAXDOP 1);