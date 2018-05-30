-----------------------------------------------------------------
-- generate code to change the recovery model 
-- for all SQL Server databases
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT 'ALTER DATABASE [' + name + '] SET RECOVERY SIMPLE;'
FROM sys.databases
WHERE database_id > 4
AND name NOT LIKE 'ReportServer%'
AND recovery_model_desc <> 'SIMPLE';