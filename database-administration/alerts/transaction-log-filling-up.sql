-----------------------------------------------------------------
-- Alerts when the transaction log of a specific database is
-- 60% full.
-- Set DATABASE_NAME
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

USE [msdb]
GO

EXEC msdb.dbo.sp_add_alert @name=N'transaction log filling up', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@performance_condition=N'Databases|Percent Log Used|DATABASE_NAME|>|60', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO