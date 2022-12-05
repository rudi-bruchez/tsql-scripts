-----------------------------------------------------------------
-- Analyze REDO waits using Extended Events
--
-- replace <database_name> placeholder.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- query the historgram
WITH cte AS (
	SELECT 
		n.value('(value)[1]', 'int') AS WaitType,
		n.value('(@count)[1]', 'int') AS WaitCount
	FROM
	(SELECT CAST(target_data AS XML) target_data
	 FROM sys.dm_xe_sessions AS s 
	 INNER JOIN sys.dm_xe_session_targets AS t
		 ON s.address = t.event_session_address
	 WHERE s.name = N'redo_waits'
	 AND t.target_name = N'histogram' ) AS tab
	CROSS APPLY target_data.nodes('HistogramTarget/Slot') AS q(n)
)
SELECT 
	mv.map_value as wait_type,
	cte.WaitCount
FROM cte 
JOIN sys.dm_xe_map_values mv ON cte.WaitType = mv.map_key
WHERE mv.name = 'wait_types'
ORDER BY cte.WaitCount DESC
OPTION (RECOMPILE, MAXDOP 1);