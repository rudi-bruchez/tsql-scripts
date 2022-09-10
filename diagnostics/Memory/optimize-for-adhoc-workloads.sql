-----------------------------------------------------------------
-- analysis for optimize for adhoc workloads    --

-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
	'total' as type,
	CAST(SUM(CAST(cp.size_in_bytes as bigint)/1024.00) / 1024 as decimal(10, 2)) AS [Plan Size in MB]
FROM sys.dm_exec_cached_plans AS cp WITH (READUNCOMMITTED)
WHERe cp.objtype <> 'Proc'
UNION ALL
SELECT
	'usecounts_1' as type,
	CAST(SUM(CAST(cp.size_in_bytes as bigint)/1024.00) / 1024 as decimal(10, 2)) AS [Plan Size in MB]
FROM sys.dm_exec_cached_plans AS cp WITH (READUNCOMMITTED)
WHERE cp.usecounts = 1 AND cp.objtype <> 'Proc'
ORDER BY type
OPTION (RECOMPILE, MAXDOP 1);