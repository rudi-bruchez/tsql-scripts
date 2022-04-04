-----------------------------------------------------------------
-- lists tables and columns 
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

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
OPTION (RECOMPILE, MAXDOP 1);