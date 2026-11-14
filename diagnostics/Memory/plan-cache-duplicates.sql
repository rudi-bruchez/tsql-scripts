-----------------------------------------------------------------
-- Find batch texts with multiple cached plans and compare cache keys
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
-- Read-only, instance-wide. Requires VIEW SERVER STATE before SQL Server
-- 2022, or VIEW SERVER PERFORMANCE STATE on SQL Server 2022 and later.
-- Different databases can legitimately have separate plans for the same text.
-- Source: https://www.pachadata.com/docs/articles/sqlserver/internals/cache-de-plans/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH plans AS (
    SELECT DISTINCT qs.sql_handle, qs.plan_handle
    FROM sys.dm_exec_query_stats AS qs
), doublons AS (
    SELECT sql_handle, COUNT(*) AS nb_plans
    FROM plans
    GROUP BY sql_handle
    HAVING COUNT(*) > 1
)
SELECT d.nb_plans,
       DB_NAME(CAST(pa.dbid AS int)) AS base,
       CAST(pa.set_options AS int) AS set_options,
       CAST(pa.user_id AS int) AS user_id,
       CAST(pa.language_id AS int) AS language_id,
       cp.usecounts,
       LEFT(t.text, 70) AS debut_du_texte
FROM doublons AS d
JOIN plans AS p ON p.sql_handle = d.sql_handle
JOIN sys.dm_exec_cached_plans AS cp ON cp.plan_handle = p.plan_handle
CROSS APPLY sys.dm_exec_sql_text(d.sql_handle) AS t
CROSS APPLY (
    SELECT dbid, set_options, user_id, language_id
    FROM (SELECT attribute, value FROM sys.dm_exec_plan_attributes(cp.plan_handle)) AS s
    PIVOT (MAX(value) FOR attribute IN (dbid, set_options, user_id, language_id)) AS pv
) AS pa
ORDER BY d.nb_plans DESC, debut_du_texte, set_options
OPTION (RECOMPILE, MAXDOP 1);
