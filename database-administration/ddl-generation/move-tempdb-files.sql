-----------------------------------------------------------------
-- Generate code to move tempdb files
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @newFolder NVARCHAR(MAX) = 'D:\Data'

SELECT 
	CONCAT('ALTER DATABASE tempdb MODIFY FILE (NAME = [' + f.name + '],',
		' FILENAME = ''', @newFolder , '\',
		reverse(left(reverse(physical_name), charindex('\', reverse(physical_name)) -1)),
		''');') as [ddl]
FROM sys.master_files f
WHERE f.database_id = DB_ID(N'tempdb')
OPTION (RECOMPILE, MAXDOP 1);
