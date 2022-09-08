-----------------------------------------------------------------
-- Analyze the SQL Server plan cache

-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

;WITH attr AS (
    SELECT plan_handle, pvt.set_options, pvt.sql_handle, pvt.date_format, pvt.date_first  
    FROM (  
		SELECT plan_handle, epa.attribute, epa.value   
		FROM sys.dm_exec_cached_plans   
		OUTER APPLY sys.dm_exec_plan_attributes(plan_handle) AS epa  
		WHERE cacheobjtype = 'Compiled Plan'  
		) AS ecpa   
    PIVOT (MAX(ecpa.value) FOR ecpa.attribute IN ("set_options", "sql_handle", "date_format", "date_first")) AS pvt
),
qs AS (
    SELECT 
	   plan_handle,
	   MIN(creation_time) AS creation_time,
	   MAX(last_execution_time) AS last_execution_time,
	   MAX(last_worker_time) AS last_worker_time,
	   MAX(last_logical_reads) AS last_logical_reads
    FROM sys.dm_exec_query_stats
    GROUP BY plan_handle
)
SELECT 
    ISNULL(DB_NAME(st.dbid),'ResourceDB') AS db,
    st.text, 
    cp.refcounts,
    cp.usecounts,
    cp.cacheobjtype,
    cp.objtype,
    cp.pool_id,
    cp.size_in_bytes,
    qs.creation_time,
    qs.last_execution_time,
    qs.last_worker_time,
    qs.last_logical_reads,
    CASE WHEN EXISTS (SELECT * FROM sys.dm_exec_cached_plan_dependent_objects(cp.plan_handle) do WHERE do.cacheobjtype = 'Cursor')
	   THEN 1
	   ELSE 0
    END as HasCursor,
    attr.set_options,
    attr.date_format,
    attr.date_first,
    ce.disk_ios_count, ce.context_switches_count,
    qp.query_plan
    --ce.original_cost, ce.current_cost,
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
OUTER APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
LEFT JOIN attr ON cp.plan_handle = attr.plan_handle
LEFT JOIN qs ON cp.plan_handle = qs.plan_handle
LEFT JOIN sys.dm_os_memory_cache_entries ce ON cp.memory_object_address = ce.memory_object_address
OPTION (RECOMPILE, MAXDOP 1);