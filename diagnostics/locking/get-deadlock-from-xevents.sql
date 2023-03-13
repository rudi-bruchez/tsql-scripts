-----------------------------------------------------------------
-- Get deadlock information from system_health xevents session
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

;WITH sh AS (
    SELECT
        timestamp_utc,
        CAST(event_data AS XML) AS eventdata
    FROM sys.fn_xe_file_target_read_file('system_health*.xel', null, null, null)
    WHERE object_name = 'xml_deadlock_report'
),
dg AS (
    SELECT *,
    eventdata.query('(event/data/value/deadlock)[1]') AS DeadlockGraph
    FROM sh
)
SELECT
    CAST(timestamp_utc as datetime2(3)) as timestamp_utc,
    DeadlockGraph.value('(/deadlock/process-list/process/@currentdbname)[1]', 'sysname') AS [db],
    DeadlockGraph.value('(/deadlock/resource-list/keylock/@objectname)[1]', 'sysname') AS [table],
    DeadlockGraph
FROM dg
ORDER BY timestamp_utc DESC
OPTION (RECOMPILE, MAXDOP 1);
