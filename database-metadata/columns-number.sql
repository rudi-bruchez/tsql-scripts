-----------------------------------------------------------------
-- List all tables in a database ordered by the number of columns 
-- starting with the highest number

-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT TABLE_NAME, MAX(ORDINAL_POSITION) as NB_COLUMNS
FROM INFORMATION_SCHEMA.COLUMNS
GROUP BY TABLE_NAME
ORDER BY NB_COLUMNS DESC;