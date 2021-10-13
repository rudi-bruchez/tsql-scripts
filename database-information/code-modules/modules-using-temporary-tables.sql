-----------------------------------------------------------------
-- find code modules with temporary tables 
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT 
	CONCAT(OBJECT_SCHEMA_NAME(o.parent_object_id) + '.' + OBJECT_NAME(o.parent_object_id) + '.', 
	SCHEMA_NAME(o.schema_id), '.', o.name) as module,
	o.type_desc as [type],
	o.create_date,
	o.modify_date,
	m.definition
FROM sys.sql_modules m
JOIN sys.objects o ON m.object_id = o.object_id
WHERE 
	o.is_ms_shipped = 0
	AND (
		m.definition LIKE '%CREATE TABLE #%'
		OR m.definition LIKE '%INTO #%'
	)
ORDER BY module;