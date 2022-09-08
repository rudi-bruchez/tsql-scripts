-----------------------------------------------------------------
-- Plan cache usage

-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	cacheobjtype, 
	CASE GROUPING(CASE WHEN usecounts = 1 THEN '1 time' ELSE 'many times' END)
		WHEN 0 THEN CASE WHEN usecounts = 1 THEN '1 time' ELSE 'many times' END
		ELSE 'TOTAL'
	END as usage,
    COUNT(*) as [count],
	CAST(SUM(CAST(size_in_bytes as bigint)) / 1000.0 / 1000 as DECIMAL(10,2)) as size_mb
FROM sys.dm_exec_cached_plans cp WITH (READUNCOMMITTED)
GROUP BY cacheobjtype,
	CASE WHEN usecounts = 1 THEN '1 time' ELSE 'many times' END
WITH ROLLUP
OPTION (RECOMPILE, MAXDOP 1);