-----------------------------------------------------------------
-- wrapper around sp_whoisactive to get relevant columns
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

USE Master;
GO

CREATE PROCEDURE dbo.sp_WhoIsRunning
AS
BEGIN
	SET NOCOUNT ON;

	EXEC sp_WhoIsActive 
	@get_plans = 1,
	@show_sleeping_spids = 0,
	-- @not_filter_type = 'host',
    -- @not_filter = 'localhost',
	@output_column_list = '[dd%][session_id][sql_text][sql_command][login_name][host_name][wait_info][cpu%][block%][reads%][context%][query_plan][locks]';
END;