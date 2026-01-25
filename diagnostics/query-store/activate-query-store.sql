-----------------------------------------------------------------------------------
-- Activate the Query Store on a database and apply recommended settings
-- (change db_name)

-- To specify the database name, use the "Specify Values for Template Parameters"
-- Navigate to Query-> Specify Values for Template Parameters.
-- Or use keyboard shortcut key Ctrl+Shift+M. 
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

ALTER DATABASE [db_name] SET QUERY_STORE = ON
(
	OPERATION_MODE = READ_WRITE, 

	-- Data retention period (30 days by default, 60 for more history)
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),

    -- Flush to disk (900 sec = 15 min by default)
    DATA_FLUSH_INTERVAL_SECONDS = 900,

   -- Maximum storage size for Query Store
   -- Default 2019+ = 1000 MB, but 2000-5000 MB recommended in production
 	MAX_STORAGE_SIZE_MB = 2000, 

    -- Stats aggregation interval (60 min by default, 30 for more granularity)
    INTERVAL_LENGTH_MINUTES = 60,

   -- Automatic cleanup when close to the limit
    SIZE_BASED_CLEANUP_MODE = AUTO,
 
    -- Capture mode: AUTO filters trivial queries
    -- ALL = capture everything (debug), NONE = pause, CUSTOM = fine rules (2019+)
	QUERY_CAPTURE_MODE = AUTO
)
GO