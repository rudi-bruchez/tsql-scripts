USE master;
GO

-----------------------------------------------------------------
-- sp_logspace, replaces DBCC SQLPERF (LOGSPACE) with more
-- information
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_logspace
    @database SYSNAME = N'%'
AS BEGIN
    SET NOCOUNT ON;

	;WITH cte_vlf AS (
		SELECT 
			ROW_NUMBER() OVER(PARTITION BY d.database_id ORDER BY li.vlf_begin_offset) AS vlfid,
			CAST(PERCENT_RANK() OVER(PARTITION BY d.database_id ORDER BY li.vlf_begin_offset) * 100 as DECIMAL(5,2)) AS pr,
			d.name AS db, 
			li.vlf_sequence_number, 
			li.vlf_active, 
			li.vlf_begin_offset, 
			li.vlf_size_mb
		FROM sys.databases d 
		CROSS APPLY sys.dm_db_log_info(d.database_id) li ),
	cte_active_vlf AS (
		SELECT db, 
			MAX(pr) as [pos]
		FROM cte_vlf
		WHERE vlf_active = 1
		GROUP BY db)
    SELECT
        d.name as [db],
		CEILING(ls.total_log_size_mb) as log_size_MB,
		CEILING(ls.active_log_size_mb) as log_used_MB,
		CEILING(ls.active_log_size_mb / NULLIF(ls.total_log_size_mb, 0) * 100) as [% used],
        NULLIF(d.log_reuse_wait_desc, N'NOTHING') as log_reuse_wait,
        d.recovery_model_desc as recovery_model,
        NULLIF(CAST(ls.log_backup_time as datetime2(0)), '1900-01-01 00:00:00') as last_translog_backup,
        mf.name,
        mf.physical_name,
        CASE mf.max_size
            WHEN 0 THEN 'Fixed'
            WHEN -1 THEN 'Illimited'
            WHEN 268435456 THEN '2 TB'
            ELSE CONCAT((mf.max_size * 8) / 1024, ' MB')
        END AS [max],
        CASE mf.growth
            WHEN 0 THEN 'Fixed'
            ELSE
                CASE mf.is_percent_growth
                    WHEN 1 THEN CONCAT(growth, '%')
                    ELSE CONCAT((mf.growth * 8) / 1024, ' MB')
                END
        END AS [growth],
		ls.total_vlf_count as vlf,
		CAST(ls.log_since_last_checkpoint_mb as decimal(38, 2)) as since_last_checkpoint_mb,
		CAST(ls.log_since_last_log_backup_mb as decimal(38, 2)) as since_last_log_backup_mb,
		CAST(ls.log_recovery_size_mb as decimal(38, 2)) as recovery_size_mb,
		av.pos as [% active position]
    FROM sys.databases d
    JOIN sys.master_files mf ON d.database_id = mf.database_id AND mf.[type] = 1 -- log
        AND mf.state <> 6 -- OFFLINE
    --OUTER APPLY (SELECT COUNT(*) as vlf FROM sys.dm_db_log_info ( d.database_id ) ) li
	CROSS APPLY sys.dm_db_log_stats( d.database_id ) ls
	LEFT JOIN cte_active_vlf av ON av.db = d.name
    WHERE d.name LIKE @database
	AND d.name NOT IN (N'master', N'model')
    ORDER BY [db]
    OPTION (MAXDOP 1);

END;
GO