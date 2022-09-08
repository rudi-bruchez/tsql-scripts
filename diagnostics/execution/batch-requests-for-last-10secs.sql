-----------------------------------------------------------------
-- Using performance counters to get the number of batch requests 
-- in 10 seconds, in average per second.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

DECLARE @CountVal BIGINT;
 
SELECT @CountVal = cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Batch Requests/sec'
OPTION (RECOMPILE, MAXDOP 1);
 
WAITFOR DELAY '00:00:10';
 
SELECT (cntr_value - @CountVal) / 10 AS 'Batch Requests/sec'
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Batch Requests/sec'
OPTION (RECOMPILE, MAXDOP 1);