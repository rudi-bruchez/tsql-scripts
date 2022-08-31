-----------------------------------------------------------------
-- List of jobs
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	j.name,
	CASE j.description
		WHEN N'No description available.' THEN ''
		WHEN N'Pas de description disponible.' THEN ''
		ELSE j.description
	END as description,
	REPLACE(c.name, '[Uncategorized (Local)]', '') as category,
	CAST(j.date_modified as date) as date_modified
FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.syscategories c ON j.category_id = c.category_id
WHERE j.enabled = 1
ORDER BY j.name
OPTION (RECOMPILE, MAXDOP 1);