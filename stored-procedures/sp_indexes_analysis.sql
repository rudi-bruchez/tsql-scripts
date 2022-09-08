USE Master;
GO

-----------------------------------------------------------------
-- Analyze missing and existing indexes for all tables
-- or a specific table in the current database.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_indexes_analysis
	@table_name sysname = '%'
AS BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	-- add the table schema if "needed"
	--IF CHARINDEX('.', @table_name) = 0 SET @table_name = CONCAT('dbo.', @table_name);

	DECLARE @sqlserver_start_time datetime2(0) = 
	(
		SELECT sqlserver_start_time 
		FROM sys.dm_os_sys_info
	);

	DECLARE @EntrepriseFeatures BIT = 0;

	IF SERVERPROPERTY('EngineEdition') IN (
		3 /* Enterprise */,
		5 /* Azure SQL Database */,
		6 /* Synapse */,
		8 /* Managed Instance */
	) BEGIN
		SET @EntrepriseFeatures = 1;
	END;

	SELECT CONCAT('SQL Server start time : ', @sqlserver_start_time) as Info;

	-- 1. missing indexes
	SELECT	
		CONCAT(OBJECT_SCHEMA_NAME(d.object_id), '.', OBJECT_NAME(d.object_id)) as [missing indexes], 
		COALESCE(d.equality_columns + ', ' + d.inequality_columns, d.equality_columns, d.inequality_columns) as [key],
		d.equality_columns,
		d.inequality_columns,
		d.included_columns,
		CAST(s.avg_total_user_cost as decimal(8,2)) as avg_total_user_cost,
		s.avg_user_impact,
		s.user_seeks + s.user_scans as usage,
		CAST(COALESCE(s.last_user_seek, s.last_user_scan) as datetime2(0)) as last_usage,
		CONCAT(
			'CREATE INDEX nix$', lower(object_name(object_id)), '$', 
			REPLACE(REPLACE(REPLACE(COALESCE(equality_columns, inequality_columns), ']', ''), '[', ''), ', ', '_'),
			' ON ', statement,' (' + COALESCE(equality_columns, inequality_columns), 
			COALESCE(') INCLUDE (' + included_columns, ''),
			') WITH (ONLINE = ', IIF(@EntrepriseFeatures = 1, 'ON', 'OFF')  , ', DATA_COMPRESSION = ROW, SORT_IN_TEMPDB = ON)'
		)as [DDL]
	FROM sys.dm_db_missing_index_details d 
	JOIN sys.dm_db_missing_index_groups g ON d.index_handle = g.index_handle
	JOIN sys.dm_db_missing_index_group_stats s ON g.index_group_handle = s.group_handle
	WHERE database_id = db_id()
	--AND CONCAT(OBJECT_SCHEMA_NAME(d.object_id), '.', OBJECT_NAME(d.object_id)) LIKE @table_name
	AND OBJECT_NAME(d.object_id) LIKE @table_name
	ORDER BY usage DESC, [missing indexes], s.user_seeks DESC, d.object_id
	OPTION (MAXDOP 1);

	-- 2. index usage
	;WITH cte AS (
		SELECT 
			MIN(SCHEMA_NAME(tn.schema_id) + '.' + tn.name) as [existing indexes],
			MIN(ix.name) AS idx,
			MIN(ix.fill_factor) as fill_factor,
			tn.object_id as object_id,
			ix.index_id,
			MIN(ix.type_desc) as idxType,
			MIN(CAST(ix.is_unique as tinyint)) as is_unique,
			MIN(CAST(ix.is_primary_key as tinyint)) as is_primary_key,
			CAST(SUM(ps.[used_page_count]) * 8.192 / 1024 as decimal(20, 2)) as IndexSizeMB,
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
			AND ix.index_id > 0 -- not heaps
		GROUP BY tn.object_id, ix.index_id
	)
	SELECT 
		cte.[existing indexes],
		cte.idx,
		CASE cte.idxType
			WHEN 'NONCLUSTERED' THEN 'NC'
			ELSE cte.idxType
		END as t,
		CONCAT(CASE cte.is_unique WHEN 1 THEN 'UQ.' ELSE '' END, CASE cte.is_primary_key WHEN 1 THEN 'PK.' ELSE '' END) as inf,
		cte.IndexSizeMB as [MB],
		cte.[key],
		cte.fill_factor as ff,
		cte.partitions,
		cte.compr,
		COALESCE(ius.user_seeks, 0) as seeks,
		COALESCE(ius.user_scans, 0) as scans,
		COALESCE(ius.user_updates, 0) as updates,
		CAST(COALESCE(ius.last_user_seek, ius.last_user_scan) as datetime2(0)) as last_usage, 
		CAST(ius.last_user_update as datetime2(0)) as last_update,
		SUM(cte.IndexSizeMB) OVER () as TotalSizeMB
		-- to generate compression code
		,CONCAT('ALTER INDEX ', QUOTENAME(cte.idx), ' ON ', cte.[existing indexes], ' REBUILD WITH (ONLINE = ', IIF(CAST(SERVERPROPERTY('Edition') as nchar(10)) = 'Enterprise', 'ON', 'OFF'), ', DATA_COMPRESSION = ROW, SORT_IN_TEMPDB = ON)') as Compression_Code
		-- to generate DROP code
		,CONCAT('DROP INDEX ', QUOTENAME(cte.idx), ' ON ', cte.[existing indexes], ';') as Drop_Code
	FROM cte
	LEFT JOIN sys.dm_db_index_usage_stats ius ON ius.object_id = cte.object_id AND ius.index_id = cte.index_id 
		AND ius.database_id = DB_ID()
	ORDER BY [existing indexes], [key]
	OPTION (MAXDOP 1);

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
END;
GO

-- to enable the procedure to run in the current dtabase context
EXEC sys.sp_MS_marksystemobject 'dbo.sp_indexes_analysis'

