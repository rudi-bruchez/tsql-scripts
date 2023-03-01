-----------------------------------------------------------------
-- get blocking information, 
-- wrapper around sp_whoisactive
-- so, sp_whoisactive must be installed (http://whoisactive.com/)
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

USE Master;
GO

CREATE PROCEDURE dbo.sp_WhoIsBlocking
AS
BEGIN
	SET NOCOUNT ON;

	EXEC sp_WhoIsActive
		@output_column_list = '[dd%][session_id][sql_text][sql_command][login_name],[blocking_session_id],[blocked_session_count],[wait_info],[status],[database_name],[program_name],[start_time],[additional_info],[tran_start_time],[tran_log_writes]',
		@find_block_leaders = 1,
		@sort_order = '[blocked_session_count] DESC',
		@get_task_info = 2,
		@get_additional_info = 1,
		@get_transaction_info = 1;

END
GO
