-----------------------------------------------------------------
-- Find all objects partitioned on a specific partition function
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
DECLARE @partition_function sysname = N'<function name here>';

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object]
	,FORMAT((SUM(p.rows) * 8.0) / 1024, 'n') AS [rows]
	,FORMAT((SUM(au.total_pages) * 8.0) / 1024, 'n') AS mb_total
	,FORMAT((SUM(au.used_pages) * 8.0) / 1024, 'n') AS mb_used
	,CASE i.index_id
		WHEN 0 THEN '(heap)'
		WHEN 1 THEN 'clustered'
		ELSE MIN(i.name) 
	END as [index]
	,i.index_id as index_id
	--,MIN(i.type_desc) as idx_type
	,MIN(au.type_desc) as alloc_type
	,MIN(p.data_compression_desc) as [compression]
FROM sys.partitions p JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.objects o ON p.object_id = o.object_id
JOIN sys.allocation_units au ON p.partition_id = au.container_id
JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id
JOIN sys.partition_functions f ON f.function_id = ps.function_id
JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id
    AND dds.destination_id = p.partition_number
JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id
LEFT JOIN sys.partition_range_values rv ON f.function_id = rv.function_id
    AND p.partition_number = rv.boundary_id
WHERE f.name = @partition_function
GROUP BY o.schema_id, i.object_id, i.index_id
ORDER BY [object], index_id
OPTION (RECOMPILE, MAXDOP 1); 