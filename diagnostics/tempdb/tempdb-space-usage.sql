-----------------------------------------------------------------
-- Tempdb space usage
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    SUM (user_object_reserved_page_count)*8 as user_obj_kb,
    SUM (internal_object_reserved_page_count)*8 as internal_obj_kb,
    SUM (version_store_reserved_page_count)*8  as version_store_kb,
    SUM (unallocated_extent_page_count)*8 as freespace_kb,
    SUM (mixed_extent_page_count)*8 as mixedextent_kb
FROM sys.dm_db_file_space_usage
OPTION (RECOMPILE, MAXDOP 1);