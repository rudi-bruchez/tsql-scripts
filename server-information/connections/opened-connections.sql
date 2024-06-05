-----------------------------------------------------------------
-- Opened Connections
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	DB_NAME(se.database_id) as [db],
	*
FROM sys.dm_exec_sessions se
WHERE is_user_process = 1
AND se.session_id <> @@SPID
AND program_name NOT LIKE 'SQLAgent - %'
AND program_name NOT LIKE 'Microsoft SQL Server Management Studio'
AND program_name NOT LIKE 'SQLServerCEIP'
AND program_name NOT LIKE 'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense'
OPTION (RECOMPILE, MAXDOP 1);