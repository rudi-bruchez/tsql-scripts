-----------------------------------------------------------------
-- Alerting on long ruinng transactions
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

USE [msdb]
GO

EXEC msdb.dbo.sp_add_alert @name=N'Long_Transactions', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=600, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@performance_condition=N'Transactions|Longest Transaction Running Time||>|60'
GO


