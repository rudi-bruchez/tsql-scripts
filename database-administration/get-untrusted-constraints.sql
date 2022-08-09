-----------------------------------------------------------------
-- get untrusted check constraints 
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	OBJECT_NAME(parent_object_id) AS TableName,
    name AS ConstraintName
FROM sys.objects
WHERE type_desc = 'CHECK_CONSTRAINT'
AND OBJECTPROPERTY([object_id], 'CnstIsNotTrusted') = 1
ORDER BY TableName, ConstraintName
OPTION (RECOMPILE, MAXDOP 1);