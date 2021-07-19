SELECT
       i.index_id,
       i.name,
       i.type_desc as [type],
       i.fill_factor,
       p.partition_number,
       p.rows,
       au.type_desc AS [type],
       au.total_pages,
       au.used_pages,
       au.used_pages * 8 / 1024 as used_mb,
       SUM(au.used_pages * 8 / 1024) OVER () as total_used_mb,
       au.data_pages,
       p.data_compression_desc as [compression]
FROM sys.partitions p
JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.allocation_units au ON au.container_id = P.partition_id
WHERE P.object_id = OBJECT_ID('<TABLE NAME>')
ORDER BY i.index_id, partition_number;