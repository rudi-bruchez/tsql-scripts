-----------------------------------------------------------------
-- find the active portion of the transaction log
-- useful before a transaction log shrink
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

WITH cte AS (
       SELECT
             file_id,
             vlf_size_mb,
             vlf_sequence_number,
             vlf_active,
             CASE vlf_status
                    WHEN 0 THEN 'inactive'
                    WHEN 1 THEN 'initialised'
                    WHEN 2 THEN 'active'
             END as vlf_status,
             SUM(vlf_size_mb) OVER (ORDER BY vlf_begin_offset) - vlf_size_mb as size_before,
             SUM(vlf_size_mb) OVER (ORDER BY vlf_begin_offset DESC) - vlf_size_mb as size_after,
             CAST(PERCENT_RANK() OVER (ORDER BY vlf_begin_offset) * 100 as DECIMAL(5, 2)) as [% position],
             SUM(vlf_size_mb) OVER () as total_size,
             COUNT(*) OVER () as vlf_number,
             vlf_begin_offset
       FROM sys.dm_db_log_info ( NULL )
)
SELECT
       MIN(vlf_number) as vlf_number,
       SUM(vlf_size_mb) as active_portion_size_mb,
       COUNT(*) as nb_active_vlf,
       MIN(size_before) as size_before_mb,
       MIN(size_after) as size_after_mb,
       MAX([% position]) as [% position],
       MIN(total_size) as total_size
FROM cte
WHERE vlf_active = 1
OPTION (RECOMPILE, MAXDOP 1);
