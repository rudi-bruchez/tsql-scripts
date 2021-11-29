-----------------------------------------------------------------
-- Get information about filegroups and objets in filegroups, 
-- in a SQL Server database
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
 
------------------------------------------------
--            files and filegroups            --
------------------------------------------------
SELECT 
	fg.name as [filegroup],
	df.name as [file_name],
	df.physical_name as [file_path]
FROM sys.filegroups fg
JOIN sys.database_files df ON fg.data_space_id = df.data_space_id
ORDER BY fg.name;

------------------------------------------------
--           objects in filegroups            --
------------------------------------------------
SELECT 
	fg.name as [filegroup],
	o.name as [table],
	i.name as [index],
	au.total_pages
FROM sys.filegroups fg
JOIN sys.allocation_units au ON fg.data_space_id = au.data_space_id
JOIN sys.partitions AS p ON au.container_id = p.partition_id
JOIN sys.objects AS o ON p.object_id = o.object_id
JOIN sys.indexes AS i ON p.index_id = i.index_id AND i.object_id = p.object_id
WHERE o.is_ms_shipped = 0
ORDER BY o.name, i.index_id;

------------------------------------------------
--            pages in filegroups             --
------------------------------------------------
SELECT 
	fg.name as [filegroup],
	SUM(au.total_pages) as total_pages
FROM sys.filegroups fg
JOIN sys.allocation_units au ON fg.data_space_id = au.data_space_id
GROUP BY fg.name
ORDER BY fg.name;