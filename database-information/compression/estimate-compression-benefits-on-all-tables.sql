-----------------------------------------------------------------
-- Estimate compression benefits on all tables
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @results TABLE (
	[object_name] sysname,
	[schema_name] sysname,
	[index_id] 	int,
	[partition_number] int,
	[size_with_current_compression_setting(KB)] bigint,
	[size_with_requested_compression_setting(KB)] bigint,
	[sample_size_with_current_compression_setting(KB)] bigint,
	[sample_size_with_requested_compression_setting(KB)] bigint
);

DECLARE table_cursor CURSOR
READ_ONLY
FOR 
	SELECT TABLE_SCHEMA, TABLE_NAME
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_TYPE = N'BASE TABLE'
	ORDER BY TABLE_SCHEMA, TABLE_NAME

DECLARE @schema_name sysname, @table_name sysname
OPEN table_cursor

FETCH NEXT FROM table_cursor INTO @schema_name, @table_name
WHILE (@@fetch_status = 0)
BEGIN
	INSERT INTO @results
	EXEC sp_estimate_data_compression_savings 
		@schema_name = @schema_name, 
		@object_name = @table_name, 
	    @index_id = NULL, 
		@partition_number = NULL, 
		@data_compression = 'ROW'

	FETCH NEXT FROM table_cursor INTO @schema_name, @table_name
END

CLOSE table_cursor
DEALLOCATE table_cursor

;WITH cte AS (
	SELECT 
		CONCAT(r.schema_name, '.', r.object_name, '.' + i.name) as [index], 
		CASE i.type_desc
			WHEN 'CLUSTERED' THEN 'CL'
			WHEN 'NONCLUSTERED' THEN 'NC'
			ELSE i.type_desc
		END as [type], 
		r.[size_with_current_compression_setting(KB)] / 1000 as current_mb, 
		r.[size_with_requested_compression_setting(KB)] / 1000 as compressed_mb,
		100 - CAST((r.[size_with_requested_compression_setting(KB)] * 1.0 / NULLIF(r.[size_with_current_compression_setting(KB)], 0)) * 100 as decimal(5,2)) as [gain_percent]
	FROM @results r
	JOIN sys.indexes i ON OBJECT_ID(r.schema_name + '.' + r.object_name) = i.object_id AND r.index_id = i.index_id
)
SELECT *,
	SUM(current_mb - compressed_mb) OVER () as total_saved_mb,
	CAST(AVG(gain_percent) OVER () as decimal(5,2)) as avg_gain_percent
FROM cte
ORDER BY [gain_percent] DESC
OPTION (RECOMPILE, MAXDOP 1);
