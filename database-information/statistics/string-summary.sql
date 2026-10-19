-----------------------------------------------------------------
-- Decode the string summary (the trie behind "String Index = YES")
-- of a statistics object, and estimate a LIKE pattern from it
--
-- Reads the statistics blob from DBCC SHOW_STATISTICS ... WITH STATS_STREAM,
-- captured with INSERT ... EXEC. Read-only.
--
-- The format is undocumented and was decoded on SQL Server 2025 CU7:
-- https://www.pachadata.com/docs/articles/sqlserver/performances/statistiques-de-chaines/
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;

DECLARE @table sysname = N'Contact.ProspectUS'; -- schema.table, in the current database
DECLARE @column sysname = N'Email';              -- first column of the statistics
DECLARE @stats sysname = NULL;                   -- statistics name, NULL for the first one on @column
DECLARE @pattern nvarchar(4000) = N'%.org';     -- LIKE pattern to estimate, NULL to skip

DECLARE @b varbinary(max), @p int, @pos int, @w int, @collation sysname,
        @nulls int, @sample int, @distinct int, @buflen int, @nodes int, @total bigint,
        @buf varbinary(max), @i int = 0, @f int, @len int, @off int, @cnt bigint,
        @parent varbinary(8000), @path varbinary(8000), @sib bit,
        @string nvarchar(400), @sql nvarchar(max);

SELECT TOP (1) @stats = s.name,
       @w = CASE WHEN c.system_type_id IN (99, 231, 239) THEN 2 ELSE 1 END, -- ntext, nvarchar, nchar
       @collation = c.collation_name
FROM sys.stats AS s
JOIN sys.stats_columns AS sc ON sc.object_id = s.object_id AND sc.stats_id = s.stats_id AND sc.stats_column_id = 1
JOIN sys.columns AS c ON c.object_id = sc.object_id AND c.column_id = sc.column_id
WHERE s.object_id = OBJECT_ID(@table)
  AND (s.name = @stats OR (@stats IS NULL AND c.name = @column))
ORDER BY s.stats_id;

IF @w IS NULL
BEGIN
    RAISERROR('Statistics not found.', 16, 1);
    RETURN;
END;

DECLARE @stream TABLE (stats_stream varbinary(max), [rows] bigint, data_pages bigint);
SET @sql = N'DBCC SHOW_STATISTICS (' + QUOTENAME(@table, '''') + N', ' + QUOTENAME(@stats) + N') WITH STATS_STREAM, NO_INFOMSGS;';
INSERT @stream EXEC (@sql);
SELECT @b = stats_stream FROM @stream;

-- The summary starts at the last 0xFF01000000 marker followed by the 40/40 truncation lengths
SET @pos = CHARINDEX(0xFF01000000, @b);
WHILE @pos > 0
BEGIN
    IF SUBSTRING(@b, @pos + 17, 8) = 0x2800000028000000 SET @p = @pos;
    SET @pos = CHARINDEX(0xFF01000000, @b, @pos + 1);
END;

IF @p IS NULL
BEGIN
    RAISERROR('No string summary in this statistics object (String Index = NO).', 16, 1);
    RETURN;
END;

-- Little-endian 4-byte integers: NULLs met by the sampling, sampled values (NULLs included),
-- distinct sampled values (NULL counts as one), then the length of the character buffer
SET @nulls    = CAST(SUBSTRING(@b, @p + 5, 1) AS int) + CAST(SUBSTRING(@b, @p + 6, 1) AS int) * 256
              + CAST(SUBSTRING(@b, @p + 7, 1) AS int) * 65536 + CAST(SUBSTRING(@b, @p + 8, 1) AS int) * 16777216;
SET @sample   = CAST(SUBSTRING(@b, @p + 9, 1) AS int) + CAST(SUBSTRING(@b, @p + 10, 1) AS int) * 256
              + CAST(SUBSTRING(@b, @p + 11, 1) AS int) * 65536 + CAST(SUBSTRING(@b, @p + 12, 1) AS int) * 16777216;
SET @distinct = CAST(SUBSTRING(@b, @p + 13, 1) AS int) + CAST(SUBSTRING(@b, @p + 14, 1) AS int) * 256
              + CAST(SUBSTRING(@b, @p + 15, 1) AS int) * 65536 + CAST(SUBSTRING(@b, @p + 16, 1) AS int) * 16777216;
SET @buflen   = CAST(SUBSTRING(@b, @p + 33, 1) AS int) + CAST(SUBSTRING(@b, @p + 34, 1) AS int) * 256
              + CAST(SUBSTRING(@b, @p + 35, 1) AS int) * 65536 + CAST(SUBSTRING(@b, @p + 36, 1) AS int) * 16777216;
SET @buf = SUBSTRING(@b, @p + 37, @buflen * @w);   -- characters, in the column encoding
SET @pos = @p + 37 + @buflen * @w;
SET @nodes    = CAST(SUBSTRING(@b, @pos, 1) AS int) + CAST(SUBSTRING(@b, @pos + 1, 1) AS int) * 256
              + CAST(SUBSTRING(@b, @pos + 2, 1) AS int) * 65536 + CAST(SUBSTRING(@b, @pos + 3, 1) AS int) * 16777216;
SET @pos += 4;

-- Nodes in preorder, 5 bytes each: flags and count, label length, label offset (3 bytes).
-- Flags: 0x80 next sibling, 0x40 has children, 0x10 count on 2 more bytes, 0x20 on 4 more bytes,
-- otherwise the low 4 bits are the count of sampled strings that end on this node.
-- Strings are kept as bytes and converted once, at the end, in the collation of the column.
DECLARE @stack TABLE (lvl int PRIMARY KEY, path varbinary(8000), sib bit);
DROP TABLE IF EXISTS #strings;
CREATE TABLE #strings (bin varbinary(8000), sampled bigint);
SET @parent = 0x;

WHILE @i < @nodes
BEGIN
    SET @f   = CAST(SUBSTRING(@b, @pos, 1) AS int);
    SET @len = CAST(SUBSTRING(@b, @pos + 1, 1) AS int);
    SET @off = CAST(SUBSTRING(@b, @pos + 2, 1) AS int) + CAST(SUBSTRING(@b, @pos + 3, 1) AS int) * 256
             + CAST(SUBSTRING(@b, @pos + 4, 1) AS int) * 65536;
    SET @pos += 5;
    SET @cnt = @f & 15;
    IF @f & 48 = 16
    BEGIN
        SET @cnt = CAST(SUBSTRING(@b, @pos, 1) AS int) + CAST(SUBSTRING(@b, @pos + 1, 1) AS int) * 256;
        SET @pos += 2;
    END
    ELSE IF @f & 48 = 32
    BEGIN
        SET @cnt = CAST(SUBSTRING(@b, @pos, 1) AS bigint) + CAST(SUBSTRING(@b, @pos + 1, 1) AS bigint) * 256
                 + CAST(SUBSTRING(@b, @pos + 2, 1) AS bigint) * 65536 + CAST(SUBSTRING(@b, @pos + 3, 1) AS bigint) * 16777216;
        SET @pos += 4;
    END
    ELSE IF @f & 48 = 48
    BEGIN
        RAISERROR('Count encoding 0x30 not seen while decoding the format: stopping.', 16, 1);
        RETURN;
    END;

    SET @path = @parent + SUBSTRING(@buf, @off * @w + 1, @len * @w);
    SET @sib = CASE WHEN @f & 128 = 128 THEN 1 ELSE 0 END;
    IF @cnt > 0 INSERT #strings VALUES (@path, @cnt);

    IF @f & 64 = 64
    BEGIN
        -- the next node is the first child of this one
        INSERT @stack VALUES ((SELECT COUNT(*) FROM @stack), @path, @sib);
        SET @parent = @path;
    END
    ELSE IF @sib = 0
    BEGIN
        -- last child: climb until an ancestor that has a next sibling
        WHILE EXISTS (SELECT * FROM @stack)
        BEGIN
            SELECT TOP (1) @sib = sib FROM @stack ORDER BY lvl DESC;
            DELETE FROM @stack WHERE lvl = (SELECT MAX(lvl) FROM @stack);
            IF @sib = 1 BREAK;
        END;
        SET @parent = ISNULL((SELECT TOP (1) path FROM @stack ORDER BY lvl DESC), 0x);
    END;
    SET @i += 1;
END;

-- The optimizer scales the selectivity by the current number of rows of the table
SELECT @total = SUM(rows) FROM sys.partitions WHERE object_id = OBJECT_ID(@table) AND index_id IN (0, 1);

SELECT @total AS table_rows, @sample AS sampled_values, @nulls AS sampled_nulls,
       @distinct AS distinct_sampled, @nodes AS trie_nodes,
       CAST(@total * 0.1 / NULLIF(@sample, 0) AS decimal(19, 2)) AS floor_estimate;

-- Strings decoded in the code page of the column, and the LIKE run in its collation.
-- A varbinary converted implicitly into a varchar column keeps its bytes; CAST or COLLATE would
-- translate them through the code page of the database.
-- Estimate of a LIKE with a wildcard, for a pattern of the type of the column (a nvarchar pattern on a
-- varchar column bypasses the summary): table rows x max(matching sampled strings, 0.1) / sampled values.
-- A LIKE without wildcard is estimated from the histogram, not from the summary.
SET @string = CASE WHEN @w = 2 THEN N'nvarchar(4000)' ELSE N'varchar(8000)' END + N' COLLATE ' + @collation;

SET @sql = N'
CREATE TABLE #decoded (string ' + @string + N', sampled bigint);
INSERT #decoded (string, sampled)
SELECT ' + CASE WHEN @w = 2 THEN N'CAST(bin AS nvarchar(4000))' ELSE N'bin' END + N', sampled FROM #strings;

SELECT string, sampled FROM #decoded ORDER BY string;

IF @pattern IS NOT NULL
    SELECT @pattern AS pattern, m.matching AS matching_sampled,
           CAST(@total * IIF(m.matching = 0, 0.1, m.matching) / NULLIF(@sample, 0) AS decimal(19, 2)) AS estimate
    FROM (SELECT ISNULL(SUM(CASE WHEN string LIKE @pattern THEN sampled END), 0) AS matching
          FROM #decoded) AS m;';

EXEC sys.sp_executesql @sql, N'@pattern nvarchar(4000), @total bigint, @sample int',
     @pattern = @pattern, @total = @total, @sample = @sample;

DROP TABLE #strings;
