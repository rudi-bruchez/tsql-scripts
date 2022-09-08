-----------------------------------------------------------------
-- gets PAGEIOLATCH statistics
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
wait_time_ms - signal_wait_time_ms as io_latch,
wait_type,
waiting_tasks_count,
wait_time_ms,
signal_wait_time_ms,
(wait_time_ms - signal_wait_time_ms) / waiting_tasks_count AS [avg_wait_time]
FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'PAGEIOLATCH%'
AND waiting_tasks_count > 0
ORDER BY wait_type 
OPTION (RECOMPILE, MAXDOP 1);