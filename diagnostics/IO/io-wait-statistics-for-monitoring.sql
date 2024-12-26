-----------------------------------------------------------------
-- current state of IO wait stats, cumulative since last restart
-- to use as a counter in Prometheus
-- ( monotonically increasing counters )
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
	SYSDATETIMEOFFSET() as [time],
    [wait_type],
    [wait_time_ms],
    ([wait_time_ms] - [signal_wait_time_ms]) AS [Resource],
    [signal_wait_time_ms],
    [waiting_tasks_count]
FROM sys.dm_os_wait_stats
WHERE [wait_type] IN (
    N'PAGEIOLATCH_SH',
    N'WRITELOG',
    N'PAGEIOLATCH_EX'
    )
OPTION (RECOMPILE, MAXDOP 1);