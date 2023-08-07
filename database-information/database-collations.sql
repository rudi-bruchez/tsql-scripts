-----------------------------------------------------------------
-- Lists databases and collations
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Default collation chosen at installation time
SELECT SERVERPROPERTY('Collation') as DefaultServerCollation;

-- Database collations
SELECT 
	name,
	collation_name
FROM sys.databases
ORDER BY name
OPTION (RECOMPILE, MAXDOP 1);