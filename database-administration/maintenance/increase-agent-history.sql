-----------------------------------------------------------------
-- increase agent job history to 10,000 rows, 500 max per job
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

USE [msdb]
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @jobhistory_max_rows=10000, 
		@jobhistory_max_rows_per_job=500
GO
