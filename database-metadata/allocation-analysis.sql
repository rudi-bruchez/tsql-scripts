SELECT p.partition_number,
       p.rows,
       au.type_desc AS [type],
       au.total_pages,
       au.used_pages,
       au.data_pages
FROM sys.partitions P
JOIN sys.allocation_units AU ON AU.container_id = P.partition_id
WHERE P.object_id = OBJECT_ID('<TABLE NAME>');