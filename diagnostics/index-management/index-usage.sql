-----------------------------------------------------------------
-- find index usage in the current database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
DECLARE @table_name sysname = '%';

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
	JOIN sys.tables tn ON tn.OBJECT_ID = ix.object_id
	WHERE 
		tn.[name] LIKE @table_name AND 
		ix.index_id > 1 -- do not take clustered index into consideration
	GROUP BY tn.object_id, ix.index_id
)
SELECT 
	cte.tbl,
	cte.idx,
	CASE cte.idxType
		WHEN 'NONCLUSTERED' THEN 'NC'
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
FROM cte
LEFT JOIN sys.dm_db_index_usage_stats ius ON ius.object_id = cte.object_id AND ius.index_id = cte.index_id 
	AND ius.database_id = DB_ID()
ORDER BY tbl;


-----------------------------------------------------------------
-- Get index usage on a specific SQL Server table  
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
SELECT sqlserver_start_time FROM sys.dm_os_sys_info;
GO

SELECT 
	SCHEMA_NAME(t.schema_id) + '.' + OBJECT_NAME(ius.object_id) as tbl,
	i.name as idx, 
	i.is_unique AS uq,
	user_seeks AS seeks, 
	user_scans AS scans, 
	user_updates AS updates, 
	CAST(last_user_seek AS DATETIME2(0)) AS last_seek, 
	CAST(last_user_scan AS DATETIME2(0)) AS last_scan, 
	CAST(last_user_update AS DATETIME2(0)) AS last_upd,
	FORMAT(ps.page_count * 8.192, 'N', 'fr-fr') as size_kb,
	ps.fragmentation AS [fragmentation %],
	i.index_id
FROM sys.dm_db_index_usage_stats ius
JOIN sys.indexes i ON ius.object_id = i.object_id AND ius.index_id = i.index_id
JOIN sys.tables t ON i.object_id = t.object_id
CROSS APPLY (SELECT SUM(page_count) as page_count, CAST(MAX(avg_fragmentation_in_percent) AS DECIMAL(5,2)) AS fragmentation FROM sys.dm_db_index_physical_stats(DB_ID(), i.object_id, i.index_id, NULL , N'LIMITED')) AS ps
WHERE ius.database_id = DB_ID()
AND ius.object_id = OBJECT_ID('<TABLE NAME>')
-- AND user_seeks = 0
AND i.type_desc = N'NONCLUSTERED'
AND i.is_primary_key = 0
ORDER BY tbl, ps.page_count DESC;