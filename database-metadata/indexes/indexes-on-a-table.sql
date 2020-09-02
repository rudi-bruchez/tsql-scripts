-----------------------------------------------------------------
-- list indexes on one table
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT 
	i.index_id,
	MIN(i.name) as index_name,
	MIN(i.type_desc) as [type],
	MIN(CAST(i.is_primary_key as tinyint)) as pk,
	MIN(CAST(i.is_unique as tinyint)) as uq,
	STUFF((	SELECT CONCAT(', ', c.name, CASE ic.is_included_column WHEN 1 THEN '[i]' ELSE '' END) AS [text()] 
		FROM sys.index_columns ic 
		JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
		WHERE i.object_id = ic.object_id AND i.index_id = ic.index_id
		ORDER BY ic.is_included_column, ic.key_ordinal
		FOR XML PATH('')
	), 1, 2, '') AS cols,
	SUM(p.rows) as [rowcount],
	COUNT(*) as [partitions],
	MIN(CAST(i.is_disabled as tinyint)) as [disabled],
	MIN(CAST(i.is_hypothetical as tinyint)) as hypothetical,
	SUM(COALESCE(ius.user_seeks + ius.user_scans, 0)) as usage 
FROM sys.indexes i
JOIN sys.partitions p ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.tables t ON i.object_id = t.object_id
LEFT JOIN sys.dm_db_index_usage_stats ius ON ius.object_id = i.object_id
	AND ius.index_id = i.index_id AND ius.database_id = DB_ID()
WHERE t.schema_id = SCHEMA_ID('dbo')
AND t.name = '<TABLE_NAME>'
GROUP BY i.object_id, i.index_id;