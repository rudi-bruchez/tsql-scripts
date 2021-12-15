-----------------------------------------------------------------
-- clean old backups
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

----------------------------------------------------
--          set variable values here
DECLARE @folderPath nvarchar(max) = N'E:\BACKUPS'
DECLARE @daysToKeep int = 7
----------------------------------------------------

DECLARE @date datetime2(0) = DATEADD(day, @daysToKeep * -1, SYSDATETIME());

DECLARE @sql nvarchar(max) = CONCAT(
	'EXECUTE master.dbo.xp_delete_file 0,N''',
	@folderPath,
	''',N''bak'',N''',
	FORMAT(@date, 'yyyy-MM-ddTHH:mm:ss'),
	''',1'
	);

PRINT (@sql);
EXEC  (@sql);
