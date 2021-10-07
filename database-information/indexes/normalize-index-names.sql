-- generate DDL to rename index according to naming conventions
-- very much a work in progress. Adapt to your liking
-- rudi@babaluga.com, go ahead license.


;WITH cte AS (
	SELECT 
		i.name, 
		--i.*,
		i.type_desc AS [type], 
		CONCAT(QUOTENAME(SCHEMA_NAME(t.schema_id)), '.', QUOTENAME(t.name)) AS [table],
		CASE i.type
			WHEN 1 THEN
				CASE i.is_primary_key
					WHEN 1 THEN CONCAT('PK_', REPLACE(SCHEMA_NAME(t.schema_id) + '_', 'dbo_', ''), t.name)
					ELSE CONCAT('CIX_', REPLACE(SCHEMA_NAME(t.schema_id) + '_', 'dbo_', ''), t.name)
				END
			WHEN 2 THEN CONCAT('NIX_', REPLACE(SCHEMA_NAME(t.schema_id) + '_', 'dbo_', ''), t.name,
			(SELECT '_' + c.name AS [text()]
				FROM sys.index_columns ic
				JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
				WHERE ic.is_included_column = 0
				AND ic.object_id = i.object_id
				AND ic.index_id = i.index_id
				ORDER BY key_ordinal
				FOR XML PATH(''))
				)
			ELSE i.name
		END AS NewName
	FROM sys.indexes i
	JOIN sys.tables t ON i.object_id = t.object_id
	WHERE i.index_id > 0
	AND T.type = 'U'
	AND T.is_ms_shipped = 0
)
SELECT *,
	CONCAT('EXEC sp_rename N''', [table], '.', name, ''', N''', NewName, ''', N''INDEX'';') AS [go]
FROM cte
ORDER BY [table];