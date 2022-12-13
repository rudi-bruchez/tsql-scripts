-----------------------------------------------------------------
-- Number of files per database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    mf.database_id,
    DB_NAME(mf.database_id) as [db],
    mf.type_desc,
    COUNT(*) as [files],
    FORMAT((CAST(SUM(mf.size) as bigint) * 8) / 1024, 'N') as size_mb
FROM sys.master_files mf
GROUP BY mf.database_id, mf.type_desc
ORDER BY mf.database_id, mf.type_desc DESC
OPTION (RECOMPILE, MAXDOP 1);