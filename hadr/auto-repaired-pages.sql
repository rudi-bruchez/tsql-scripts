-----------------------------------------------------------------
-- Looks if correupted pages were auto repaired
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	DB_NAME(apr.database_id) as [database],
	apr.file_id,
	apr.page_id,
	apr.error_type,
	apr.page_status,
	apr.modification_time
FROM sys.dm_hadr_auto_page_repair apr
ORDER BY [database]
OPTION (RECOMPILE, MAXDOP 1);