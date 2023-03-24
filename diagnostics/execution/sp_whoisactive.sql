-----------------------------------------------------------------
-- example of using sp_whoisactive
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

-- with query plans
EXEC sp_whoisactive @get_plans = 1

-- short view

EXEC sp_WhoIsActive 
	@get_plans = 1,
	@show_sleeping_spids = 0,
	@not_filter_type = 'host',
    @not_filter = 'SERVERNAME', -- change this to actual server name to exclude it from the results
	@output_column_list = '[dd%][session_id][sql_text][sql_command][login_name][host_name][wait_info][cpu%][block%][reads%][context%][query_plan][locks]';