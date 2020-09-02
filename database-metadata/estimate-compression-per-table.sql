DECLARE @results TABLE (
	[object_name] sysname,
	[schema_name] sysname,
	[index_id] 	int,
	[partition_number] int,
	[size_with_current_compression_setting(KB)] bigint,
	[size_with_requested_compression_setting(KB)] bigint,
	[sample_size_with_current_compression_setting(KB)] bigint,
	[sample_size_with_requested_compression_setting(KB)] bigint
)

INSERT INTO @results
EXEC sp_estimate_data_compression_savings @schema_name = 'dbo', @object_name = 'table name', 
    @index_id = NULL, @partition_number = NULL, @data_compression = 'ROW' -- 'COLUMNSTORE' since SQL Server 2019    

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
		100 - CAST((r.[size_with_requested_compression_setting(KB)] * 1.0 / r.[size_with_current_compression_setting(KB)]) * 100 as decimal(5,2)) as [gain_percent]
	FROM @results r
	JOIN sys.indexes i ON OBJECT_ID(r.schema_name + '.' + r.object_name) = i.object_id AND r.index_id = i.index_id
)
SELECT *,
	SUM(current_mb - compressed_mb) OVER () as total_saved_mb,
	CAST(AVG(gain_percent) OVER () as decimal(5,2)) as avg_gain_percent
FROM cte
ORDER BY cte.[type];