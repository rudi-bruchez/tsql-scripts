-----------------------------------------------------------------
-- Lists pages in buffer per type
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT page_type, COUNT(*) as cnt
FROM sys.dm_os_buffer_descriptors b 
WHERE b.database_id = DB_ID()
GROUP BY page_type
ORDER BY cnt DESC
OPTION (RECOMPILE, MAXDOP 1);