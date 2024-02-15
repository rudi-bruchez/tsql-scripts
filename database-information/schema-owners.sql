-----------------------------------------------------------------
-- Lists database schemas and their owners, to check if some
-- schemas are owned other users than dbo.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT s.schema_id, s.name as [schema], p.name as [owner]
FROM sys.schemas s
JOIN sys.database_principals p ON s.principal_id = p.principal_id
WHERE s.schema_id NOT BETWEEN 16384 AND 16393 -- fixed database roles
AND schema_id > 4 -- system schemas
ORDER BY [schema]
OPTION (RECOMPILE, MAXDOP 1);