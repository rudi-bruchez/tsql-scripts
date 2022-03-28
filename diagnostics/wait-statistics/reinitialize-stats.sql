-----------------------------------------------------------------
-- Reinitialize wait stats
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR);