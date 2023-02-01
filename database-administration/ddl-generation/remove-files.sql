-----------------------------------------------------------------
-- Removes uneccessary secondary files
-- 
-- Removes excessive secondary files. People seem to want to have 
-- a lot of files, who knows why.
--
-- This script will keep one data files per filegroup, performing
-- two steps :

-- 1. increase max file size if needed
-- 2. shrink and remove other files
-- 
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

DECLARE @debug bit = 1 -- dry run

SET NOCOUNT ON;

-- 1. gather information

DROP TABLE IF EXISTS #files -- SQL Server 2016 onwards

SELECT 
	mf.name, 
	--CAST(mf.size as bigint) * 8192 as size,
	CAST(mf.size as bigint) * 8192 / 1048576 as FileSize_Mb,
	mf.max_size,
	ds.name as fg,
	--SUM(CAST(mf.size as bigint) * 8192) OVER (PARTITION BY mf.data_space_id) as sum_fg,
	SUM(CAST(mf.size as bigint) * 8192) OVER (PARTITION BY mf.data_space_id) / 1048576 as sum_fg_MB,
	ROW_NUMBER() OVER (PARTITION BY mf.data_space_id ORDER BY mf.file_id) as rn,
	mf.physical_name,
	vs.volume_mount_point as [drive],
	--vs.total_bytes,
	--vs.available_bytes,
	vs.total_bytes/1048576 as DriveSize_MB, 
    vs.available_bytes/1048576 as DriveFree_MB
INTO #files
FROM sys.master_files mf
JOIN sys.data_spaces ds ON mf.data_space_id = ds.data_space_id
CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) vs
WHERE mf.type = 0 -- rows
AND mf.database_id = DB_ID()
ORDER BY mf.name;

-- 2. increase max file size if needed

DECLARE cur1 CURSOR
FAST_FORWARD
FOR 
	SELECT
		CASE
			WHEN max_size = 0 THEN 1 -- no groth allowed
			WHEN max_size = 1 THEN 0 -- unlimited
			WHEN (CAST(max_size as bigint) * 8192 / 1048576) < sum_fg_MB THEN 1
			ELSE 0
		END AS ok,
		CONCAT('ALTER DATABASE ', QUOTENAME(DB_NAME()), ' MODIFY FILE ( NAME = N''', name, ''', MAXSIZE = ', sum_fg_MB ,'MB , FILEGROWTH = 100MB )') as ddl
	FROM #files
	WHERE rn = 1

DECLARE 
	@ok bit,
	@ddl nvarchar(max)

OPEN cur1

FETCH NEXT FROM cur1 INTO @ok, @ddl
WHILE (@@fetch_status = 0)
BEGIN
	IF @ok = 1
	BEGIN
		PRINT @ddl
		IF @debug = 0 EXEC(@ddl);
	END
	FETCH NEXT FROM cur1 INTO @ok, @ddl
END

CLOSE cur1
DEALLOCATE cur1

-- 3. shrink and remove other files

DECLARE cur2 CURSOR
FAST_FORWARD
FOR 
	SELECT name
	FROM #files
	WHERE rn > 1

DECLARE 
	@filename sysname

OPEN cur2

FETCH NEXT FROM cur2 INTO @filename
WHILE (@@fetch_status = 0)
BEGIN
	SET @ddl = CONCAT('DBCC SHRINKFILE (N''', @filename , ''' , EMPTYFILE)');
	PRINT @ddl
	IF @debug = 0 EXEC(@ddl);

	SET @ddl = CONCAT('ALTER DATABASE ', QUOTENAME(DB_NAME()) , ' REMOVE FILE ', QUOTENAME(@filename));
	PRINT @ddl
	IF @debug = 0 EXEC(@ddl);

	FETCH NEXT FROM cur2 INTO @filename
END

CLOSE cur2
DEALLOCATE cur2
GO
