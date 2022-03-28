-----------------------------------------------------------------
-- find the path of the SQL Serverlog directory
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT 
	LEFT(CAST(SERVERPROPERTY('ErrorLogFileName') as nvarchar(max)), 
		LEN(CAST(SERVERPROPERTY('ErrorLogFileName') as nvarchar(max))) - LEN('ERRORLOG'));