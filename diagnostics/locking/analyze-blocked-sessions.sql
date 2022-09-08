-----------------------------------------------------------------
-- blocking sessions

-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

;WITH
    cte
    AS
    (
        SELECT DISTINCT
            CAST(ws1.wait_duration_ms / 1000.0 as decimal(10, 2)) as wait_duration_sec,
            ws1.wait_type as wait_type,
            ws1.session_id as session_id,
            ws1.blocking_session_id as blocking_session_id,
            ws1.resource_description,
            CHARINDEX('objid=',ws1.resource_description) + 6 AS resource_description_start,
            der.command,
            CASE 
            WHEN der.statement_start_offset > 0 AND der.statement_end_offset > 0 THEN 
                SUBSTRING(txt.text, 
                    der.statement_start_offset / 2, 
                    (der.statement_end_offset - der.statement_start_offset) / 2) 
            ELSE txt.text END as text_offset,
            OBJECT_NAME(txt.objectid, der.database_id) as [proc],
            der.database_id
        FROM sys.dm_os_waiting_tasks ws1
            JOIN sys.dm_exec_sessions ses ON ws1.blocking_session_id = ses.session_id
            JOIN sys.dm_exec_requests der ON ws1.session_id = der.session_id
            OUTER APPLY sys.dm_exec_sql_text (der.sql_handle) txt

        WHERE ws1.blocking_session_id > 0
            AND ws1.blocking_session_id <> ws1.session_id
            AND ws1.wait_type LIKE 'LCK%'
            AND ses.session_id NOT IN (SELECT ws2.session_id
            FROM sys.dm_os_waiting_tasks ws2
            WHERE ws2.blocking_session_id > 0)
    ),
    cte2
    AS
    (
        SELECT wait_duration_sec
        , wait_type
        , session_id
        , blocking_session_id
        , resource_description
        , resource_description_start
        , command
        , text_offset
        , [proc]
        , database_id
        , TRY_CAST(SUBSTRING(resource_description, resource_description_start,
        CHARINDEX(' ', resource_description, resource_description_start)-resource_description_start) AS INT) AS [object_id]
        FROM cte
    )
SELECT 
    *
    , DB_NAME(database_id) as [db]
	, OBJECT_NAME(object_id, database_id) AS [table]
FROM cte2
OPTION (RECOMPILE, MAXDOP 1);