-----------------------------------------------------------------
-- SQL Server Memory Statistics
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

-- Creation of a temporary table to store results
IF OBJECT_ID('tempdb..#sql_memory_stats') IS NOT NULL
    DROP TABLE #sql_memory_stats;

CREATE TABLE #sql_memory_stats (
    Metric NVARCHAR(100),
    Value_MB INT
);

-- Maximum memory configured for SQL Server
INSERT INTO #sql_memory_stats (Metric, Value_MB)
SELECT 'Max server memory (MB)', CAST(value_in_use as int)
FROM sys.configurations
WHERE name = 'max server memory (MB)';

-- Total physical memory of the system
INSERT INTO #sql_memory_stats (Metric, Value_MB)
SELECT 'Total system memory (MB)', available_physical_memory_kb / 1024
FROM sys.dm_os_sys_memory;

-- Memory actually used by SQL Server
INSERT INTO #sql_memory_stats (Metric, Value_MB)
SELECT 'SQL Server memory in use (MB)', physical_memory_in_use_kb / 1024
FROM sys.dm_os_process_memory;

-- Locked pages if enabled
INSERT INTO #sql_memory_stats (Metric, Value_MB)
SELECT 'Locked pages (MB)', locked_page_allocations_kb / 1024
FROM sys.dm_os_process_memory;

-- Buffer pool
INSERT INTO #sql_memory_stats (Metric, Value_MB)
SELECT 'Buffer pool size (MB)', COUNT(*) * 8 / 1024
FROM sys.dm_os_buffer_descriptors
WHERE database_id <> 32767;

-- Memory reserved by SQL Server (committed VAS)
INSERT INTO #sql_memory_stats (Metric, Value_MB)
SELECT 'SQL Server committed VAS (MB)', virtual_address_space_committed_kb / 1024
FROM sys.dm_os_process_memory;

-- Memory reserved by memory type (example: Buffer Pool only)
INSERT INTO #sql_memory_stats (Metric, Value_MB)
SELECT 'Memory Clerk - Buffer Pool (MB)', SUM(virtual_memory_committed_kb) / 1024
FROM sys.dm_os_memory_clerks
WHERE type = 'MEMORYCLERK_SQLBUFFERPOOL';

SELECT * FROM #sql_memory_stats ORDER BY Metric;
