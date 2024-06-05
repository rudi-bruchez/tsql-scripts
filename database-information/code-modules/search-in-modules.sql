-----------------------------------------------------------------
-- Search in modules
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @string nvarchar(max) = N'';

SELECT 
	m.object_id, 
	o.name,
	o.type_desc as [type],
	o.create_date
FROM sys.sql_modules m
JOIN sys.objects o ON m.object_id = o.object_id
WHERE m.definition LIKE CONCAT(N'%', @string, N'%')
ORDER BY o.name
OPTION (RECOMPILE, MAXDOP 1);