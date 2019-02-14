-----------------------------------------------------------------
-- Number of objects per type in database 

-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT 
    type_desc as [object type],
    COUNT(*) as cnt
FROM sys.objects
WHERE [type] NOT IN ('S', 'IT')
GROUP BY type_desc
ORDER BY type_desc;