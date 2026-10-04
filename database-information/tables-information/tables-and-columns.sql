-----------------------------------------------------------------
-- lists tables and columns 
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

;WITH [rows] AS (
	SELECT 
		SCHEMA_NAME(t.schema_id) AS SchemaName,
		t.NAME AS TableName,
		SUM(p.[rows]) AS [rows]
	FROM sys.tables t
	JOIN  sys.partitions p ON t.object_id = p.OBJECT_ID
	WHERE p.index_id < 2
	GROUP BY t.schema_id, t.NAME
)
SELECT CONCAT(c.TABLE_SCHEMA, '.', c.TABLE_NAME) as tbl,
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
JOIN [rows] r ON c.TABLE_SCHEMA = r.SchemaName AND c.TABLE_NAME = r.TableName 
-- uncomment to list only some data types
/*
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
	N'ntext',
	N'float',
	N'uniqueidentifier'
)
*/
ORDER BY r.[rows] DESC, tbl, Pos
OPTION (RECOMPILE, MAXDOP 1);