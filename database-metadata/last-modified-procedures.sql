-----------------------------------------------------------------
-- Last modified stored procedures in a database 
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT 
	SCHEMA_NAME(p.schema_id) as [schema], 
	p.name,
	p.create_date,
	p.modify_date
FROM sys.procedures p
WHERE p.is_ms_shipped = 0
ORDER BY modify_date DESC;