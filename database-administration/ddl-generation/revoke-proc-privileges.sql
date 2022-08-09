-----------------------------------------------------------------
-- Code to generate REVOKE commands on EXEC privileges for
-- every procedure and for every database users and roles
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT 'REVOKE EXEC ON [' + SCHEMA_NAME(p.schema_id) + '].[' + P.name + '] TO [' + dp.name + ']'
FROM sys.procedures p
CROSS JOIN sys.database_principals dp
WHERE p.type IN ('P', 'PC')
OPTION (RECOMPILE, MAXDOP 1);