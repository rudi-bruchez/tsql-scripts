-----------------------------------------------------------------
-- Get databases compatibility level
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT d.name
	  ,d.database_id
	  ,d.compatibility_level
	  ,SERVERPROPERTY('ProductMajorVersion') AS ServerVersion
FROM sys.databases d
OPTION (RECOMPILE, MAXDOP 1);