-----------------------------------------------------------------
-- granting permissions at the server level for diagnostics
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

use [master]
GO

-- create the server role
CREATE SERVER ROLE [audit]
GO

-- permission to create and run extended event sessions
GRANT ALTER ANY EVENT SESSION TO [audit]
-- permission to create and run profiler (sql trace) sessions
GRANT ALTER TRACE TO [audit]
-- permission to view object and code definitions
GRANT VIEW ANY DEFINITION TO [audit]
-- permission to run most of the DMV
GRANT VIEW SERVER STATE TO [audit]
GO

-- Add a login to the server role
ALTER SERVER ROLE [audit] ADD MEMBER [<login>]
GO
