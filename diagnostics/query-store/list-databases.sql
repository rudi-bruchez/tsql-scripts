-----------------------------------------------------------------
-- check is the query store is enabled on some databases.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	d.name,
	d.database_id,
	d.create_date,
	d.state_desc as [state]
FROM sys.databases d
WHERE d.is_query_store_on = 1
OPTION (RECOMPILE, MAXDOP 1);