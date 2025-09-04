-----------------------------------------------------------------
-- Global Runtime Stats
--
-- copied from code behind Query Store report in SSMS
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    CONVERT(float, SUM(rs.count_executions)) as total_count_executions,
    ROUND(CONVERT(float, SUM(rs.avg_duration*rs.count_executions))*0.001,2) as total_duration,
    ROUND(CONVERT(float, SUM(rs.avg_cpu_time*rs.count_executions))*0.001,2) as total_cpu_time,
    ROUND(CONVERT(float, SUM(rs.avg_logical_io_reads*rs.count_executions))*8,2) as total_logical_io_reads,
    DATEADD(d, ((DATEDIFF(d, 0, rs.last_execution_time))),0 ) as bucket_start,
    DATEADD(d, (1 + (DATEDIFF(d, 0, rs.last_execution_time))), 0) as bucket_end
FROM xtsprod.sys.query_store_runtime_stats rs
GROUP BY DATEDIFF(d, 0, rs.last_execution_time)
OPTION (RECOMPILE, MAXDOP 1);