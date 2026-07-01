-----------------------------------------------------------------
-- Search index used in the execution plans stored in the 
-- Query Store
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;



DECLARE @indexName sysname = '';

SET @indexName = CONCAT('//Object[@Index = "', @indexName, '"]')

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

;WITH XMLNAMESPACES (
    DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
),
QueryStorePlansXML AS (
    SELECT 
        q.query_id,
        p.plan_id,
        q.object_id,
        qt.query_sql_text,
        p.last_execution_time,
        TRY_CONVERT(XML, p.query_plan) AS [query_plan_xml]
    FROM sys.query_store_plan p
    JOIN sys.query_store_query q ON p.query_id = q.query_id
    JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id
)
SELECT 
    query_id,
    plan_id,
    object_id,
    OBJECT_NAME(object_id) AS [Object_Name],
    query_sql_text,
    query_plan_xml,
    last_execution_time
FROM QueryStorePlansXML
WHERE query_plan_xml.exist(@indexName) = 1
OPTION (RECOMPILE);