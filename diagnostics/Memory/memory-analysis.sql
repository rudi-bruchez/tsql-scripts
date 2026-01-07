-----------------------------------------------------------------
-- Memory Analysis
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    'Max server memory' AS metric,
    CAST(value_in_use AS VARCHAR(20)) + ' Mo' AS [value]
FROM sys.configurations WHERE name = 'max server memory (MB)'
UNION ALL
SELECT
    'Total memory used',
    CAST(SUM(pages_kb) / 1024 AS VARCHAR(20)) + ' Mb'
FROM sys.dm_os_memory_clerks
UNION ALL
SELECT
    'Buffer Pool',
    CAST(cntr_value / 1024 AS VARCHAR(20)) + ' Mb'
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Database pages' AND object_name LIKE '%Buffer Manager%'
UNION ALL
SELECT
    'Page Life Expectancy',
    CAST(cntr_value AS VARCHAR(20)) + ' seconds'
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Page life expectancy' AND object_name LIKE '%Buffer Manager%'
UNION ALL
SELECT
    'Memory Grants Pending',
    CAST(cntr_value AS VARCHAR(20)) + ' queries'
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Memory Grants Pending' AND object_name LIKE '%Memory Manager%'
OPTION (RECOMPILE, MAXDOP 1);