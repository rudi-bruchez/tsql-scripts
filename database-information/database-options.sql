-----------------------------------------------------------------
-- Lists common database options.
-- compatible with Azure SQL Database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
	db.[name] AS db
   ,db.recovery_model_desc AS recovery_model
   ,db.containment_desc AS containment
   ,db.[compatibility_level]
   ,db.page_verify_option_desc AS [page_verify]
   ,db.is_auto_create_stats_on AS auto_create_stats
   ,db.is_auto_update_stats_on AS auto_update_stats
   ,db.is_auto_update_stats_async_on AS auto_update_stats_async
   ,db.is_auto_create_stats_incremental_on AS auto_create_stats_incremental
   ,db.is_parameterization_forced AS parameterization_forced
   ,db.snapshot_isolation_state_desc AS snapshot_isolation
   ,db.is_read_committed_snapshot_on AS RCSI
   ,db.is_auto_close_on AS [auto_close]
   ,db.is_auto_shrink_on AS [auto_shrink]
   ,db.target_recovery_time_in_seconds AS recovery_time
   ,db.is_cdc_enabled AS cdc
   ,db.is_published
   ,db.group_database_id
   ,db.replica_id
   ,db.is_memory_optimized_elevate_to_snapshot_on
   ,db.delayed_durability_desc AS [delayed_durability]
FROM sys.databases AS db
ORDER BY db.[name]
OPTION (RECOMPILE, MAXDOP 1);
