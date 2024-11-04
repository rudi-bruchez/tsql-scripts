-----------------------------------------------------------------
-- fn_maintenanceOperation
-- Returns the start time of the oldest maintenance operation in
-- progress. Useful to determine if a maintenance operation is
-- running and how long it has been running.
-- I am using it to prevent running an operation that would
-- conflict with the schema stability locks held by maintenance
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

USE master;
-- USE _dba;
GO

CREATE OR ALTER FUNCTION dbo.fn_maintenanceOperation
(
	@database_name sysname
)
RETURNS DATETIME2(3)
AS BEGIN
	RETURN (
		SELECT CAST(MIN(r.start_time) as DATETIME2(3))
		FROM sys.dm_exec_requests r
		JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
		WHERE command IN (N'UPDATE STATISTICS', N'DBCC')
		AND s.database_id = DB_ID(N'xtsprod')
	)
END;