-----------------------------------------------------------------
-- find index usage in the current database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
SELECT sqlserver_start_time, 
	DATEDIFF(day, sqlserver_start_time, CURRENT_TIMESTAMP) as days_online,
	DATEDIFF(hour, sqlserver_start_time, CURRENT_TIMESTAMP) as hours_online
FROM sys.dm_os_sys_info
OPTION (RECOMPILE, MAXDOP 1);
GO

-------------------------------------------------------
DECLARE @table_name sysname = '%';
DECLARE @index_id int = NULL;
DECLARE @include_heaps_and_clustered bit = 1;
DECLARE @only_uncompressed bit = 0;
-------------------------------------------------------

;WITH cte AS (
	SELECT 
		MIN(SCHEMA_NAME(tn.schema_id) + '.' + tn.name) as tbl,
		MIN(ix.name) AS idx,
		MIN(ix.fill_factor) as fill_factor,
		tn.object_id as object_id,
		ix.index_id,
		MIN(ix.type_desc) as idxType,
		MIN(CAST(ix.is_unique as tinyint)) as is_unique,
		MIN(CAST(ix.is_primary_key as tinyint)) as is_primary_key,
		SUM(ps.[used_page_count]) * 8 AS IndexSizeKB,
		FORMAT(SUM(ps.[used_page_count]) * 8.192 / 1024, 'N', 'fr-fr') as IndexSizeMBformatted,
		CONCAT(STUFF((SELECT ', ' + c.name as [text()]
				FROM sys.index_columns ic
				JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
				WHERE ic.object_id = tn.object_id AND ic.index_id = ix.index_id
				AND ic.is_included_column = 0
				ORDER BY ic.key_ordinal
				FOR XML PATH('')), 1, 2, ''), ' (' +
			STUFF((SELECT ', ' + c.name as [text()]
				FROM sys.index_columns ic
				JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
				WHERE ic.object_id = tn.object_id AND ic.index_id = ix.index_id
				AND ic.is_included_column = 1
				ORDER BY ic.key_ordinal
				FOR XML PATH('')), 1, 2, '') + ')') as [key],
		COUNT(p.partition_id) as partitions,
		MAX(p.data_compression_desc) as compr
	FROM sys.partitions p
	JOIN sys.dm_db_partition_stats AS ps ON p.object_id = ps.object_id
		AND p.index_id = ps.index_id AND p.partition_id = ps.partition_id
	JOIN sys.indexes AS ix ON ps.[object_id] = ix.[object_id] AND ps.[index_id] = ix.[index_id]
	JOIN sys.tables tn ON tn.object_id = ix.object_id
	WHERE 
		tn.[name] LIKE @table_name 
		AND (ix.index_id = COALESCE(@index_id, ix.index_id))
		AND (ix.index_id > 1 OR @include_heaps_and_clustered = 1 OR @index_id IS NOT NULL)
		AND (p.data_compression_desc = N'NONE' OR @only_uncompressed = 0)
	GROUP BY tn.object_id, ix.index_id
)
SELECT 
	cte.tbl,
	cte.idx,
	cte.index_id,
	CASE cte.idxType
		WHEN 'NONCLUSTERED' THEN 'NC'
		WHEN 'CLUSTERED' THEN 'CL'
		ELSE cte.idxType
	END as t,
	CONCAT(CASE cte.is_unique WHEN 1 THEN 'UQ.' ELSE '' END, CASE cte.is_primary_key WHEN 1 THEN 'PK.' ELSE '' END) as inf,
	cte.IndexSizeMBformatted as [MB],
	cte.[key],
	cte.fill_factor as ff,
	cte.partitions,
	cte.compr,
	COALESCE(ius.user_seeks, 0) as seeks,
	COALESCE(ius.user_scans, 0) as scans,
	COALESCE(ius.user_updates, 0) as updates,
	CAST(COALESCE(ius.last_user_seek, ius.last_user_scan) as datetime2(0)) as last_usage, 
	CAST(ius.last_user_update as datetime2(0)) as last_update,
	SUM(cte.IndexSizeKB) OVER () / 1024 as TotalSizeMB
	-- to generate compression code
	--,CONCAT('ALTER INDEX ', QUOTENAME(cte.idx), ' ON ', cte.tbl, ' REBUILD WITH (ONLINE = ', IIF(CAST(SERVERPROPERTY('Edition') as nchar(10)) = 'Enterprise', 'ON', 'OFF'), ', DATA_COMPRESSION = ROW, SORT_IN_TEMPDB = ON, FILLFACTOR = 90)') as DDL_COMPRESSION
	-- to generate DROP code
	--,CONCAT('DROP INDEX ', QUOTENAME(cte.idx), ' ON ', cte.tbl, ';') as DDL_DROP
FROM cte
LEFT JOIN sys.dm_db_index_usage_stats ius ON ius.object_id = cte.object_id AND ius.index_id = cte.index_id 
	AND ius.database_id = DB_ID()
ORDER BY tbl, [key]
OPTION (RECOMPILE, MAXDOP 1);
