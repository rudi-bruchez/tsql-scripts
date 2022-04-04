SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
GO

IF OBJECT_ID('tempdb..#HeapList') IS NOT NULL
    DROP TABLE #HeapList

CREATE TABLE #HeapList
    (
    object_name sysname
    ,page_count int
    ,avg_page_space_used_in_percent float
    ,record_count int
    ,forwarded_record_count int
    )

DECLARE HEAP_CURS CURSOR FOR
    SELECT object_id
    FROM sys.indexes i
    WHERE index_id = 0

DECLARE @IndexID int

OPEN HEAP_CURS
FETCH NEXT FROM HEAP_CURS INTO @IndexID

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO #HeapList
    SELECT object_name(object_id) as ObjectName
        ,page_count
        ,CAST(avg_page_space_used_in_percent as NUMERIC(5, 2))
        ,record_count
        ,forwarded_record_count
    FROM sys.dm_db_index_physical_stats (db_id(), @IndexID,  0, null,  'DETAILED'); 

    FETCH NEXT FROM HEAP_CURS INTO @IndexID
END

CLOSE HEAP_CURS
DEALLOCATE HEAP_CURS

SELECT *
FROM #HeapList
WHERE forwarded_record_count > 0
ORDER BY 1
