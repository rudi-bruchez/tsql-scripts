-----------------------------------------------------------------
-- Get index sizes
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT 
	tn.name AS [Table], 
	ix.name AS [Index],
	MIN(ix.fill_factor) as fill_factor,
	ix.index_id,
	SUM(ps.[used_page_count]) * 8 AS [size KB],
	FORMAT(SUM(ps.[used_page_count]) * 8.192, 'N', 'fr-fr') as [size formatted],
	STUFF((SELECT ', ' + c.name as [text()]
	 FROM sys.index_columns ic
	 JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
	 WHERE ic.object_id = tn.object_id AND ic.index_id = ix.index_id
	 ORDER BY ic.key_ordinal
	 FOR XML PATH('')), 1, 2, '') as [key]
FROM sys.dm_db_partition_stats AS ps
JOIN sys.indexes AS ix ON ps.[object_id] = ix.[object_id] AND ps.[index_id] = ix.[index_id]
JOIN sys.tables tn ON tn.OBJECT_ID = ix.object_id
WHERE 
	--tn.[name] = '<TABLE NAME>' AND 
	ix.index_id > 1
GROUP BY tn.[name], ix.[name], ix.index_id, tn.object_id
ORDER BY 
	tn.[name], 
	[size KB] DESC;
