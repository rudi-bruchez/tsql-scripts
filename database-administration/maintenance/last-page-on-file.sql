-----------------------------------------------------------------
-- Last page on file, with object_id and index_id.
-- Useful before shrinking a file, to know which object is on the 
-- last page.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

DECLARE @file_id int, @page_id int, @last_page_id int

SELECT
    @file_id = file_id,
    @last_page_id = size - 1
FROM sys.database_files
WHERE type = 0
AND file_id = 1;    -- fichiers de données

SET @page_id = @last_page_id;
--SELECT @file_id, @page_id

WHILE 1 = 1
BEGIN
	IF (SELECT object_id FROM sys.dm_db_page_info(
         DB_ID(), @file_id, @page_id, 'LIMITED')) IS NULL
    BEGIN
        SET @page_id -= 1
    END ELSE BEGIN
        SELECT 
            @last_page_id - @page_id as page_from_the_end,
            object_id,
            OBJECT_NAME(object_id) as object_name,
            index_id
        FROM sys.dm_db_page_info(DB_ID(), @file_id, @page_id, 'LIMITED')
        BREAK
    END
END