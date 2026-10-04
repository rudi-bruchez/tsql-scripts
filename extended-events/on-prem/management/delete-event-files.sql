SET NOCOUNT ON;
SET STATISTICS IO, TIME OFF;
GO

-- remember the current values, to put them back at the end
IF OBJECT_ID('tempdb..#config') IS NOT NULL
	DROP TABLE #config;
SELECT name, CAST(value_in_use AS int) AS value
INTO #config
FROM sys.configurations
WHERE name IN (N'show advanced options', N'xp_cmdshell');
GO

EXECUTE sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
EXECUTE sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
GO

-------------------------------------------------------------
-- SET EVENT SESSION NAME HERE :
DECLARE @session_name sysname = N'<xevent session name>';
-------------------------------------------------------------

DECLARE @logpath nvarchar(max) = 
	LEFT(CAST(SERVERPROPERTY('ErrorLogFileName') as nvarchar(max)), 
		LEN(CAST(SERVERPROPERTY('ErrorLogFileName') as nvarchar(max))) - LEN('ERRORLOG'));

IF OBJECT_ID('tempdb..#DirectoryTree')IS NOT NULL
      DROP TABLE #DirectoryTree;

CREATE TABLE #DirectoryTree (
       id int IDENTITY(1,1)
      ,subdirectory nvarchar(512)
      ,depth int
      ,isfile bit);

DECLARE @xp_dirtree NVARCHAR(MAX) = CONCAT('EXEC master.sys.xp_dirtree ''', @logpath, ''',1,1');

INSERT #DirectoryTree (subdirectory,depth,isfile)
EXEC (@xp_dirtree);

DECLARE cur CURSOR
READ_ONLY
FOR SELECT subdirectory 
	FROM #DirectoryTree
	WHERE isfile = 1 
	AND RIGHT(subdirectory,4) = '.xel'
	AND subdirectory LIKE CONCAT(@session_name, '%')


DECLARE @file sysname;
OPEN cur

FETCH NEXT FROM cur INTO @file
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN

		DECLARE @cmd nvarchar(max)
		SET @cmd = CONCAT('EXEC xp_cmdshell ''del "', @logpath, @file, '"''');
		PRINT @cmd
		EXEC( @cmd );
	END
	FETCH NEXT FROM cur INTO @file
END

CLOSE cur
DEALLOCATE cur
GO

-- put back the values found at the start
IF (SELECT value FROM #config WHERE name = N'xp_cmdshell') = 0
BEGIN
	EXECUTE sp_configure 'xp_cmdshell', 0;
	RECONFIGURE;
END
GO
IF (SELECT value FROM #config WHERE name = N'show advanced options') = 0
BEGIN
	EXECUTE sp_configure 'show advanced options', 0;
	RECONFIGURE;
END
GO
