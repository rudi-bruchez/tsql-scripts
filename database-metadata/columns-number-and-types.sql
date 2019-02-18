-----------------------------------------------------------------
-- List all tables in a database ordered by the number of columns 
-- starting with the highest number

-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT TABLE_NAME, MAX(ORDINAL_POSITION) as NB_COLUMNS
FROM INFORMATION_SCHEMA.COLUMNS
GROUP BY TABLE_NAME
ORDER BY NB_COLUMNS DESC;

;WITH [rows] AS (
	SELECT 
		t.NAME AS TableName,
		p.[Rows]
	FROM sys.tables t
	JOIN  sys.partitions p ON t.object_id = p.OBJECT_ID
	WHERE p.index_id < 2
)
SELECT TABLE_NAME as tbl,
          '  ['+column_name+'] ' 
          +  data_type 
          + case data_type
                when 'sql_variant' then ''
                when 'text' then ''
                when 'ntext' then ''
                when 'decimal' then '(' + cast(numeric_precision as varchar) + ', ' + cast(numeric_scale as varchar) + ')'
              else 
              coalesce(
                '('+ case when character_maximum_length = -1 
                    then 'MAX' 
                    else cast(character_maximum_length as varchar) end 
                + ')','') 
            end 
        + ' ' 
        + (case when IS_NULLABLE = 'No' then 'NOT ' else '' end) 
        + 'NULL ' 
        + case when c.COLUMN_DEFAULT IS NOT NULL THEN 'DEFAULT '+ c.COLUMN_DEFAULT 
          ELSE '' 
          END as col,
        ORDINAL_POSITION as Pos,
		r.[rows]
FROM INFORMATION_SCHEMA.COLUMNS c
JOIN [rows] r ON c.TABLE_NAME = r.TableName 
WHERE DATA_TYPE IN (
	N'timestamp',
	N'bigint',
	N'text',
	N'nvarchar',
	N'char',
	N'money',
	N'binary',
	N'xml',
	N'datetime',
	N'image',
	N'bit',
	N'varbinary',
	N'text',
	N'ntext',
	N'float',
	N'double',
	N'uniqueidentifier'
)
ORDER BY r.[rows] DESC

SELECT 
    t.NAME AS TableName,
    i.name as indexName,
    p.[Rows],
	a.type_desc,
    --sum(a.total_pages) as TotalPages, 
    a.used_pages
    --sum(a.data_pages) as DataPages,
    --(sum(a.total_pages) * 8) / 1024 as TotalSpaceMB, 
    --(sum(a.used_pages) * 8) / 1024 as UsedSpaceMB, 
    --(sum(a.data_pages) * 8) / 1024 as DataSpaceMB
FROM sys.tables t
JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
JOIN sys.allocation_units a ON p.partition_id = a.container_id
JOIN sys.columns c ON c.object_id = t.object_id
WHERE 
    t.NAME NOT LIKE 'dt%' AND
    i.OBJECT_ID > 255 AND   
    i.index_id <= 1 AND
	c.system_type_id IN (SELECT system_type_id
						FROM sys.types
						WHERE name IN (N'text', N'image', N'ntext'))
--GROUP BY 
--    t.NAME, i.object_id, i.index_id, i.name, p.[Rows]
ORDER BY 
    object_name(i.object_id) 

