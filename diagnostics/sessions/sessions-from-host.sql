-----------------------------------------------------------------
-- Get sessions from a specific host
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @hostname sysname = N'%';

SELECT 
	s.[session_id], 
	s.[login_time], 
	s.[last_request_end_time] as last_request, 
	s.[host_name], 
	CASE s.[program_name] 
		WHEN '.Net SqlClient Data Provider' THEN '.Net'
		ELSE s.[program_name]
	END as program, 
	s.[host_process_id], 
	CASE s.[client_interface_name] 
		WHEN '.Net SqlClient Data Provider' THEN '.Net'
		ELSE s.[client_interface_name]
	END as interface, 
	s.[login_name], 
	s.[status], 
	s.[total_elapsed_time], 
	--s.[last_request_start_time], 
	s.[open_transaction_count] as trancount,
	(	SELECT STRING_AGG(CONCAT(sw.wait_type, ' (', sw.wait_time_ms, ')'), ', ') 
		FROM [sys].[dm_exec_session_wait_stats] sw 
		WHERE s.session_id = sw.session_id
		AND sw.wait_time_ms > 0) as waits
FROM sys.dm_exec_sessions s
WHERE host_name LIKE @hostname
AND is_user_process = 1
/* -- some filters
AND s.program_name NOT LIKE 'Microsoft SQL Server Management Studio%'
AND s.program_name NOT LIKE 'Telegraf%'
AND s.program_name NOT LIKE 'SQLAgent%'
*/
ORDER BY host_name, login_time
OPTION (RECOMPILE, MAXDOP 1);