-----------------------------------------------------------------
-- 
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    qs.execution_count
   ,qs.last_rows
   ,SUBSTRING(st.text, (qs.statement_start_offset / 2) + 1,
	((CASE qs.statement_end_offset WHEN - 1 
		THEN DATALENGTH(st.text) 
		ELSE QS.statement_end_offset 
	END - QS.statement_start_offset) / 2) + 1) AS stmt
   ,qp.query_plan
   ,CAST(qs.creation_time as datetime2(0)) as creation_time
   ,CAST(qs.last_worker_time / 1000.0 as numeric(18, 2)) as last_w_t_ms
   ,CAST(qs.last_execution_time as datetime2(0)) as last_exec_time
   ,CAST(qs.min_worker_time / 1000.0 as numeric(18, 2)) as min_w_t_ms
   ,CAST(qs.max_worker_time / 1000.0 as numeric(18, 2)) as max_w_t_ms
   ,CAST(qs.last_elapsed_time / 1000.0 as numeric(18, 2)) as last_elapsed_t_ms
   ,CAST(qs.min_elapsed_time / 1000.0 as numeric(18, 2)) as min_elapsed_t_ms
   ,CAST(qs.max_elapsed_time / 1000.0 as numeric(18, 2)) as max_elapsed_t_ms
   ,qs.last_logical_reads
   ,qs.last_rows
   ,qs.last_clr_time
   --,qs.statement_sql_handle
   --,qs.statement_context_id
   ,qs.last_dop
   ,qs.max_dop
   ,qs.last_grant_kb
   ,qs.last_used_grant_kb
   ,qs.total_spills
   ,qs.last_spills
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE qs.execution_count > 1
AND qs.last_execution_time >= DATEADD(hour, -1, CURRENT_TIMESTAMP)
AND st.dbid = DB_ID()
ORDER BY last_elapsed_t_ms DESC
OPTION (RECOMPILE, MAXDOP 1);