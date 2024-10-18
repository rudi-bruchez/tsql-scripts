-----------------------------------------------------------------
-- Stored Procedure Stats from Query Store
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @procedure_name SYSNAME = 'dbo.procedure_name'

SELECT
    q.query_id
   --,q.batch_sql_handle
   ,q.query_hash
   --,q.query_parameterization_type
   ,q.query_parameterization_type_desc AS parameterization_type
   ,q.initial_compile_start_time
   ,q.last_compile_start_time
   ,q.last_execution_time
   ,q.last_compile_batch_sql_handle
   ,q.last_compile_batch_offset_start
   ,q.last_compile_batch_offset_end
   ,q.count_compiles
   ,q.avg_compile_duration
   ,q.last_compile_duration
   ,q.avg_bind_duration
   ,q.last_bind_duration
   ,q.avg_bind_cpu_time
   ,q.last_bind_cpu_time
   ,q.avg_optimize_duration
   ,q.last_optimize_duration
   ,q.avg_optimize_cpu_time
   ,q.last_optimize_cpu_time
   ,q.avg_compile_memory_kb
   ,q.last_compile_memory_kb
   ,q.max_compile_memory_kb
   ,qcs.context_settings_id
   ,qcs.set_options
   ,qcs.language_id
   ,qcs.date_format
   ,qcs.date_first
   ,qcs.status
   ,qcs.required_cursor_options
   ,qcs.acceptable_cursor_options
   ,qcs.merge_action_type
   ,qcs.default_schema_id
   ,qcs.is_replication_specific
   ,qcs.is_contained
   ,qsrs.runtime_stats_id
   ,qsrs.plan_id
   ,qsrs.runtime_stats_interval_id
   ,qsrs.execution_type
   ,qsrs.execution_type_desc
   ,qsrs.first_execution_time
   ,qsrs.last_execution_time
   ,qsrs.count_executions
   ,qsrs.avg_duration
   ,qsrs.last_duration
   ,qsrs.min_duration
   ,qsrs.max_duration
   ,qsrs.stdev_duration
   ,qsrs.avg_cpu_time
   ,qsrs.last_cpu_time
   ,qsrs.min_cpu_time
   ,qsrs.max_cpu_time
   ,qsrs.stdev_cpu_time
   ,qsrs.avg_logical_io_reads
   ,qsrs.last_logical_io_reads
   ,qsrs.min_logical_io_reads
   ,qsrs.max_logical_io_reads
   ,qsrs.stdev_logical_io_reads
   ,qsrs.avg_logical_io_writes
   ,qsrs.last_logical_io_writes
   ,qsrs.min_logical_io_writes
   ,qsrs.max_logical_io_writes
   ,qsrs.stdev_logical_io_writes
   ,qsrs.avg_physical_io_reads
   ,qsrs.last_physical_io_reads
   ,qsrs.min_physical_io_reads
   ,qsrs.max_physical_io_reads
   ,qsrs.stdev_physical_io_reads
   ,qsrs.avg_clr_time
   ,qsrs.last_clr_time
   ,qsrs.min_clr_time
   ,qsrs.max_clr_time
   ,qsrs.stdev_clr_time
   ,qsrs.avg_dop
   ,qsrs.last_dop
   ,qsrs.min_dop
   ,qsrs.max_dop
   ,qsrs.stdev_dop
   ,qsrs.avg_query_max_used_memory
   ,qsrs.last_query_max_used_memory
   ,qsrs.min_query_max_used_memory
   ,qsrs.max_query_max_used_memory
   ,qsrs.stdev_query_max_used_memory
   ,qsrs.avg_rowcount
   ,qsrs.last_rowcount
   ,qsrs.min_rowcount
   ,qsrs.max_rowcount
   ,qsrs.stdev_rowcount
   ,qsrs.avg_num_physical_io_reads
   ,qsrs.last_num_physical_io_reads
   ,qsrs.min_num_physical_io_reads
   ,qsrs.max_num_physical_io_reads
   ,qsrs.stdev_num_physical_io_reads
   ,qsrs.avg_log_bytes_used
   ,qsrs.last_log_bytes_used
   ,qsrs.min_log_bytes_used
   ,qsrs.max_log_bytes_used
   ,qsrs.stdev_log_bytes_used
   ,qsrs.avg_tempdb_space_used
   ,qsrs.last_tempdb_space_used
   ,qsrs.min_tempdb_space_used
   ,qsrs.max_tempdb_space_used
   ,qsrs.stdev_tempdb_space_used
   ,qsrs.avg_page_server_io_reads
   ,qsrs.last_page_server_io_reads
   ,qsrs.min_page_server_io_reads
   ,qsrs.max_page_server_io_reads
   ,qsrs.stdev_page_server_io_reads
   ,qsrs.replica_group_id
   ,qsrsi.runtime_stats_interval_id
   ,qsrsi.start_time
   ,qsrsi.end_time
   ,qsrsi.comment
   ,qsp.engine_version
   ,qsp.compatibility_level
   ,qsp.query_plan
   ,qsp.is_online_index_plan
   ,qsp.is_trivial_plan
   ,qsp.is_parallel_plan
   ,qsp.is_forced_plan
   ,qsp.is_natively_compiled
   ,qsp.force_failure_count
   ,qsp.last_force_failure_reason
   ,qsp.last_force_failure_reason_desc
   ,qsp.count_compiles
   ,qsp.initial_compile_start_time
   ,qsp.last_compile_start_time
   ,qsp.last_execution_time
   ,qsp.avg_compile_duration
   ,qsp.last_compile_duration
   ,qsp.plan_forcing_type
   ,qsp.plan_forcing_type_desc
   ,qsp.has_compile_replay_script
   ,qsp.is_optimized_plan_forcing_disabled
   ,qsp.plan_type_desc
    --qt.*
FROM sys.query_store_query_text AS qt
JOIN sys.query_store_query AS q
     ON q.query_text_id = qt.query_text_id
JOIN sys.query_store_plan qsp ON q.query_id = qsp.query_id
JOIN sys.query_context_settings qcs
    ON q.context_settings_id = qcs.context_settings_id
JOIN sys.query_store_runtime_stats qsrs
    ON qsp.plan_id = qsrs.plan_id
JOIN sys.query_store_runtime_stats_interval qsrsi
    ON qsrs.runtime_stats_interval_id = qsrsi.runtime_stats_interval_id
WHERE q.object_id = OBJECT_ID(@procedure_name)
AND q.is_internal_query = 0
ORDER BY qsrs.last_execution_time DESC
OPTION (RECOMPILE, MAXDOP 1);