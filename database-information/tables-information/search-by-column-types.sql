-----------------------------------------------------------------
-- Search all columns in the current database that have a 
-- specific data type
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    COLUMN_DEFAULT,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
    DATA_TYPE IN ('datetime', 'date', 'time', 'datetime2', 'datetimeoffset') -- date and time
ORDER BY TABLE_SCHEMA, TABLE_NAME, ORDINAL_POSITION
OPTION (RECOMPILE, MAXDOP 1);
