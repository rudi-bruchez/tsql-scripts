-- adapted from https://www.sqlrx.com/list-partitioned-tables-and-other-info-about-them/
SELECT 
	SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object]
	,p.partition_number AS [p]
	,fg.name AS [filegroup]
	,p.rows
	,au.total_pages AS pages
	,CASE boundary_value_on_right
	WHEN 1 THEN '<'
	ELSE '<=' END AS comparison
	,rv.value
	,i.name as [index]
	,i.index_id
	,i.type_desc
	,au.type_desc
	,au.total_pages
	,au.used_pages
	,p.data_compression_desc
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
--WHERE o.object_id = OBJECT_ID('dbo.Table');
ORDER BY o.name, i.index_id, p.partition_number