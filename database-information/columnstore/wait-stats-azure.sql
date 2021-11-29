SELECT 
	wait_type, 
    waiting_tasks_count AS [Count],
	CAST(wait_time_ms/ 1000.0 AS DECIMAL (16, 2)) AS [Wait S],
    CAST((wait_time_ms - signal_wait_time_ms) / 1000.0 AS DECIMAL (16, 2)) AS [Resource S],
    CAST(signal_wait_time_ms / 1000.0 AS DECIMAL (16, 2)) AS [Signal S],
	max_wait_time_ms
FROM sys.dm_db_wait_stats WITH (READUNCOMMITTED)
WHERE [wait_type] IN (
    N'BPSORT', -- acces to batch hash table
	N'HTMEMO',
	N'HTDELETE',
	N'HTBUILD',
	N'COLUMNSTORE_BUILD_THROTTLE',
	N'HTREPARTITION',
	N'BMPBUILD')
AND waiting_tasks_count > 0
ORDER BY [Wait S] DESC
OPTION (RECOMPILE, MAXDOP 1);