-----------------------------------------------------------------
-- Activate the Query Store on a database
-- (change db_name)
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE [master]
GO
ALTER DATABASE [db_name] SET QUERY_STORE = ON
GO
ALTER DATABASE [db_name] 
SET QUERY_STORE (
	OPERATION_MODE = READ_WRITE, 
	MAX_STORAGE_SIZE_MB = 2000, 
	QUERY_CAPTURE_MODE = AUTO)
GO
