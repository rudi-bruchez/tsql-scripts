USE Master;
GO

-----------------------------------------------------------------
-- Analyze fragmentation of a table or an index in the current 
-- database.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

CREATE OR ALTER PROCEDURE dbo.sp_indexFragmentation
	@schema_name sysname = 'dbo',
	@table_name  sysname = '%',
    @index_name  sysname = '%'
AS BEGIN
    SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SELECT 
        T.name AS [table]
        ,i.name AS [index]
        ,i.index_id
        ,i.fill_factor
        ,ps.partition_number AS [partition]
        ,ps.page_count as pages
        ,ps.compressed_page_count as compressed_pages
        ,CAST(ps.avg_page_space_used_in_percent as decimal(5,2)) as [avg_pg_used_%]
        ,CASE i.type_desc
            WHEN 'CLUSTERED' THEN 'c'
            WHEN 'CLUSTERED COLUMNSTORE' THEN 'cc'
            WHEN 'NONCLUSTERED' THEN 'nc'
            ELSE i.type_desc
        END as [type]
        ,CASE ps.alloc_unit_type_desc
            WHEN 'IN_ROW_DATA' THEN 'IN_ROW'
            ELSE ps.alloc_unit_type_desc
        END as [alloc]
        --,CAST(ps.avg_fragment_size_in_pages as decimal(18,2)) as avg_fragment_size_in_pages
        ,CAST(ps.avg_fragmentation_in_percent as decimal(5,2)) as [avg_frag_%]
        ,ps.avg_record_size_in_bytes as avg_row_byte
        ,ps.forwarded_record_count as forwarded_rec
        ,ps.fragment_count as fragments
        ,ps.ghost_record_count
        ,ps.version_ghost_record_count
        ,ps.index_depth
        ,ps.record_count as [rows]
    FROM sys.indexes i
    JOIN sys.tables t ON i.object_id = t.object_id
    CROSS APPLY sys.dm_db_index_physical_stats(DB_ID(), i.object_id, i.index_id, NULL, N'LIMITED') ps
    WHERE t.name LIKE @table_name
    AND i.name LIKE @index_name
    AND t.schema_id = SCHEMA_ID(@schema_name)
    AND ps.page_count > 0
    ORDER BY [table], i.index_id
    OPTION (MAXDOP 1);

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
END;
GO

-- to enable the procedure to run in the current dtabase context
EXEC sys.sp_MS_marksystemobject 'dbo.sp_indexFragmentation';
