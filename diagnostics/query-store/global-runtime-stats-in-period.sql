-----------------------------------------------------------------
-- Global Runtime Stats in Period
--
-- copied from code behind Query Store report in SSMS
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE 
	@interval_start_time datetimeoffset(7) ='2025-07-28 17:11:25.6737048 +02:00',
	@interval_end_time datetimeoffset(7) = '2025-08-28 17:11:25.6737048 +02:00'

SELECT
    CONVERT(float, SUM(rs.count_executions)) as total_count_executions,
    ROUND(CONVERT(float, SUM(rs.avg_duration*rs.count_executions))*0.001,2) as total_duration,
    ROUND(CONVERT(float, SUM(rs.avg_cpu_time*rs.count_executions))*0.001,2) as total_cpu_time,
    ROUND(CONVERT(float, SUM(rs.avg_logical_io_reads*rs.count_executions))*8,2) as total_logical_io_reads,
    DATEADD(d, ((DATEDIFF(d, 0, rs.last_execution_time))),0 ) as bucket_start,
    DATEADD(d, (1 + (DATEDIFF(d, 0, rs.last_execution_time))), 0) as bucket_end
FROM xtsprod.sys.query_store_runtime_stats rs
WHERE NOT (rs.first_execution_time > @interval_end_time OR rs.last_execution_time < @interval_start_time)
GROUP BY DATEDIFF(d, 0, rs.last_execution_time)
ORDER BY bucket_start
OPTION (RECOMPILE, MAXDOP 1);