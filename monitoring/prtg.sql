-----------------------------------------------------------------
-- Get perf counter in prtg format
-- Works on a default instance (SQLServer:) and a named one (MSSQL$<name>:)
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

;WITH cte AS (
	SELECT 
		CONCAT('\', TRIM(object_name), '(' + TRIM(NULLIF(instance_name, '')) + ')', '\', TRIM(counter_name)) as prtg,
		cntr_value
	FROM sys.dm_os_performance_counters
	WHERE 
	(
		(RTRIM(object_name) LIKE N'%:Batch Resp Statistics' AND counter_name = N'Batches >=100000ms') OR
		(RTRIM(object_name) LIKE N'%:Buffer Manager' AND counter_name IN (N'Buffer cache hit ratio', N'Buffer cache hit ratio base', N'Page life expectancy')) OR
		(RTRIM(object_name) LIKE N'%:Databases' AND counter_name IN (N'Active Transactions', N'Data File(s) Size (KB)', N'Log File(s) Used Size (KB)', N'Log Growths', N'Percent Log Used', N'Transactions/sec')) OR
		(RTRIM(object_name) LIKE N'%:General Statistics' AND counter_name IN (N'Active Temp Tables', N'Processes blocked', N'User Connections')) OR
		(RTRIM(object_name) LIKE N'%:Memory Manager' AND counter_name IN (N'Memory Grants Pending')) OR
		(RTRIM(object_name) LIKE N'%:SQL Errors' AND counter_name = N'Errors/sec' AND instance_name = N'User Errors') OR
		(RTRIM(object_name) LIKE N'%:SQL Statistics' AND counter_name = N'Batch Requests/sec') OR
		(RTRIM(object_name) LIKE N'%:Wait Statistics' AND counter_name IN (N'Memory grant queue waits', N'Lock waits') AND instance_name = N'Waits in progress')
	)
	AND instance_name NOT IN (N'master', N'model', N'msdb', N'mssqlsystemresource', N'_Total')
)
SELECT *,
	CASE 
		WHEN prtg LIKE '\%:Batch Resp Statistics%'
		  OR prtg LIKE '\%:Databases(%)\Log Growths'
		  OR prtg LIKE '\%:Databases(%)\Transactions/sec'
		  OR prtg LIKE '\%:SQL Errors(User Errors)\Errors/sec'
		  OR prtg LIKE '\%:SQL Statistics\Batch Requests/sec'
		THEN 1 ELSE 0 
	END as cumulative
FROM cte
ORDER BY prtg
OPTION (RECOMPILE, MAXDOP 1);
