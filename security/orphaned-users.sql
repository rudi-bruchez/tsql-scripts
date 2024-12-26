-----------------------------------------------------------------
-- Find orphaned users
-- ie, database users that are not mapped to a login
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- adapted from https://learn.microsoft.com/en-us/sql/sql-server/failover-clusters/troubleshoot-orphaned-users-sql-server
SELECT dp.type_desc, dp.sid, dp.name AS user_name  
FROM sys.database_principals AS dp  
LEFT JOIN sys.server_principals AS sp ON dp.sid = sp.sid  
WHERE dp.type = N'S'
AND sp.sid IS NULL  
AND dp.authentication_type_desc = 'INSTANCE'
OPTION (RECOMPILE, MAXDOP 1);