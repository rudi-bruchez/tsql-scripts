-----------------------------------------------------------------
-- Last modified objects in a database 
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT type_desc, name, modify_date
FROM sys.objects
WHERE modify_date > DATEADD(week, -1, CURRENT_TIMESTAMP)
AND type_desc NOT IN (N'SYSTEM_TABLE')
OPTION (RECOMPILE, MAXDOP 1);