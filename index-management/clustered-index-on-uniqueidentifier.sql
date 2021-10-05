
SELECT OBJECT_NAME(ic.object_id) AS tbl, t.name AS [type]
FROM sys.index_columns ic
JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
JOIN sys.types t ON c.system_type_id = t.system_type_id
WHERE ic.is_included_column = 0
AND ic.key_ordinal = 1
AND ic.index_id = 1
AND t.name IN (N'uniqueidentifier')
ORDER BY tbl
OPTION (RECOMPILE, MAXDOP 1);