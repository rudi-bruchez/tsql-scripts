-----------------------------------------------------------------
-- Number of objects per type in database 

-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
    type_desc as [object type],
    COUNT(*) as cnt
FROM sys.objects
WHERE [type] NOT IN ('S', 'IT')
GROUP BY type_desc
ORDER BY type_desc
OPTION (RECOMPILE, MAXDOP 1);