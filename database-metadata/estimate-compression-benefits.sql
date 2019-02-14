---------------------------------------------------------------------------------------------------
-- Estimate compression savings for all index on a table
-- code adapted from Glenn Gerry : 
-- https://www.sqlskills.com/blogs/glenn/estimating-data-compression-savings-in-sql-server-2012/

-- rudi@babaluga.com, go ahead license
---------------------------------------------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @Schema sysname = N'dbo';
DECLARE @Table sysname = N'table';

DECLARE @CompressionType nvarchar(60) = N'ROW'; -- desired data compression type (PAGE, ROW, or NONE)

CREATE TABLE #compression_savings (
    object_name sysname,
    schema_name sysname,
    index_id int,
    partition_number int,
    size_with_current_compression_setting bigint,
    size_with_requested_compression_setting bigint,
    sample_size_with_current_compression_setting bigint,
    sample_size_with_requested_compression_setting bigint
)

DECLARE cur CURSOR FAST_FORWARD
FOR
    SELECT i.index_id
    FROM sys.indexes i
    JOIN sys.tables t
    ON i.[object_id] = t.[object_id]
    WHERE t.type_desc = N'USER_TABLE'
    AND OBJECT_NAME(t.[object_id]) = @Table
    AND SCHEMA_NAME(t.Schema_id) = @Schema
    ORDER BY i.index_id;

OPEN cur;

DECLARE @idx int;
FETCH NEXT FROM cur INTO @idx;

WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO #compression_savings
        EXEC sp_estimate_data_compression_savings @Schema, @Table, @Idx, NULL, @CompressionType;

        FETCH NEXT FROM cur INTO @idx;
    END

CLOSE cur;
DEALLOCATE cur;

;WITH cte AS (
    SELECT QUOTENAME(schema_name) + '.' + QUOTENAME(object_name) as [table],
        i.name as [index],
        100 - CAST((100.0 * size_with_requested_compression_setting) / NULLIF(size_with_current_compression_setting, 0) as decimal(5, 2)) as [% to gain],
        CAST(size_with_current_compression_setting / 1024.0 as decimal (20,2)) as [current size MB],
        CAST(size_with_requested_compression_setting / 1024.0 as decimal (20,2)) as [compressed size MB]
    FROM #compression_savings cs
    JOIN sys.indexes i ON cs.index_id = i.index_id AND i.object_id = OBJECT_ID(QUOTENAME(schema_name) + '.' + QUOTENAME(object_name))
)
SELECT *,
    [current size MB] - [compressed size MB] as [saved size MB],
    SUM([current size MB] - [compressed size MB]) OVER () as [total saved MB]
FROM cte;