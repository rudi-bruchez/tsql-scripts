----------------------------------------------------------------------
-- Use the sqlos ring_buffer to get info about the last 256 minutes  
-- of scheduler activity
-- adapted from Glenn Berry
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @ts bigint, @cpu_count int;

SELECT 
	@ts = cpu_ticks/(cpu_ticks/ms_ticks),
	@cpu_count = cpu_count
FROM sys.dm_os_sys_info WITH (READUNCOMMITTED)
OPTION (RECOMPILE);

;WITH ring_buffer AS (
	SELECT
		CAST(DATEADD(millisecond, -1 * (@ts - [timestamp]), CURRENT_TIMESTAMP) as datetime2(0)) AS [Time],
		CAST(record as XML) as record
	FROM sys.dm_os_ring_buffers
	WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
	AND record LIKE N'%<SystemHealth>%'
),
cte AS (
	SELECT 
		[time],
		record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS [Idle], 
		record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS [% SQL Process],
		CAST(record.value('(./Record/SchedulerMonitorEvent/SystemHealth/UserModeTime)[1]', 'bigint') / 10000.0 / @cpu_count as decimal(20,2)) AS [UserModeTime_ms], -- output is 100ns
		CAST(record.value('(./Record/SchedulerMonitorEvent/SystemHealth/KernelModeTime)[1]', 'bigint') / 10000.0 / @cpu_count as decimal(20,2)) AS [KernelModeTime_ms],
		record.value('(./Record/SchedulerMonitorEvent/SystemHealth/PageFaults)[1]', 'bigint') AS [PageFaults],  
		record.value('(//Record/SchedulerMonitorEvent/SystemHealth/WorkingSetDelta)[1]', 'bigint')/1024 AS [WorkingSetDelta],  
		record.value('(//Record/SchedulerMonitorEvent/SystemHealth/MemoryUtilization)[1]', 'bigint') AS [% Memory Usage]
	FROM ring_buffer
)
SELECT
	[time],
	[% SQL Process],
	PageFaults,
	WorkingSetDelta,
	100 - [% SQL Process] - Idle as [% CPU other],
	CAST((100 * KernelModeTime_ms) / (UserModeTime_ms + KernelModeTime_ms) as decimal(5, 2)) As [% Kernel]
FROM cte
ORDER BY [time]
OPTION (RECOMPILE, MAXDOP 1);