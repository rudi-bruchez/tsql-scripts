-----------------------------------------------------------------
-- rebuild heap table for defragmentation 
-- written by Tibor Karaszi 
-- https://karaszi.com/rebuild-all-fragmented-heaps
-----------------------------------------------------------------

USE [_dba]
GO
-- dbo.rebuild_heaps @report_type = 'all'

ALTER PROC [dbo].[rebuild_heaps]
 @report_type varchar(20) = 'none'		--Do SELECT to show all tables names etc that were rebuilt: "none", "all", "fragmented_only"
,@print_sql_commands tinyint = 1		--Print the ALTER TABLE commands
,@exec_sql_commands tinyint = 0			--Execute the SQL command (0 basically means "report only")
,@smallest_table_size_mb int = 10		--Do not rebuild if table is smaller than
,@largest_table_size_mb bigint = 50000	--Do not rebuild if table is bigger than
,@fragmentation_level int = 15			--Rebuild if fragmentation in percent is higher than this value
,@free_space_level int = 30				--Rebuild if free space is higher than this value
AS
--Written by Tibor Karaszi 2014-03-06
--Modified 2014-03-20: Added option to rebuild based on free space, the @free_space_level parameter
--Modified 2014-06-04: By Chuck Rhoads. Added logic so we don't rebuild because lot of free space due to large row size. Thanks Chuck!
--Modified 2015-01-20: Reported by Chuck Rhoads. Added QUOTENAME to support databases which requires quoted identifiers. Thanks Chuck!
--Modified 2015-03-24: Karel Coenye, Case sensitivity and always on availability groups
--Modified 2018-09-10: Rudi Bruchez, taking avg_fragmentation_in_percent into account

SET NOCOUNT ON

SET @report_type=lower(@report_type)
IF @report_type NOT IN('none', 'all', 'fragmented_only')
BEGIN
	RAISERROR('Invalid value for @report_type. Valid values are "none", "all" and "fragmented_only"', 16, 1)
	RETURN -101
END

--Table to hold result from sys.dm_db_index_physical_stats
CREATE TABLE #heap_frag(
 object_id int NOT NULL
,page_count bigint NOT NULL
,record_count bigint NOT NULL
,forwarded_record_count bigint NOT NULL
,avg_page_space_used_in_percent tinyint NOT NULL
,Max_Page_Space_Perc decimal(10,2) NOT NULL
,Page_Space_Dev decimal(10,2) NOT NULL
,avg_fragmentation_in_percent tinyint NOT NULL)

DECLARE 
 @db_id int
,@db_name sysname
,@object_id int
,@schema_name sysname
,@table_name sysname
,@page_count bigint
,@record_count bigint
,@forwarded_record_count bigint
,@avg_page_space_used_in_percent tinyint
,@sql nvarchar(3000)
,@fwd_rows_percentage tinyint
,@msg nvarchar(3000)
,@heap_size_mb bigint
,@tables_in_database int
,@heaps_in_database int
,@fragmented_heaps_in_database int
,@Max_Page_Space_Perc decimal(10,2)
,@Page_Space_Dev decimal(10,2)
,@avg_fragmentation_in_percent tinyint
,@version int
,@cluster sysname
,@CurrentAvailabilityGroup sysname
,@CurrentAvailabilityGroupRole sysname

SET @version= CAST(LEFT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - 1) + '.' + REPLACE(RIGHT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)), LEN(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)))),'.','') AS numeric(18,10))

--Table to output fragmentation report, if requested
EXEC('IF OBJECT_ID(''tempdb..##frag_report'') IS NOT NULL DROP TABLE ##frag_report')
CREATE TABLE ##frag_report --Global, so we can SELECT from other connection while executing
(id bigint IDENTITY(1,1) PRIMARY KEY
,database_name sysname
,schema_name sysname
,table_name sysname
,size_in_mb int
,pages bigint
,rows_ bigint
,forwarded_rows bigint
,fragmentation_level tinyint
,avg_page_space_used_in_percent tinyint
,Max_Page_Space_Perc decimal(10,2)
,Page_Space_Dev decimal(10,2)
,avg_fragmentation_in_percent tinyint)


DECLARE @Databases table (
	Database_id int,
	DatabaseName sysname,
	CurrentAvailabilityGroup sysname null,
	CurrentAvailabilityGroupRole sysname null,
	CurrentDatabaseMirroringRole sysname null,
	ClusterName sysname null
)

INSERT INTO @Databases (Database_id,DatabaseName)
SELECT d.database_id, d.name 
	FROM sys.databases AS d 
	where d.database_id > 4
	and d.state_desc = 'ONLINE'
	and d.is_auto_close_on = 0 -- Added for issues known to be related to autoclose=on
	and d.name IN (
		N'wp_abr',
		N'wp_chrono',
		N'wp_chrono_sko',
		N'wp_fpim',
		N'wp_holding',
		N'wp_max',
		N'wp_maxipneu',
		N'wp_pfp2',
		N'wp_requ',
		N'wp_simon',
		N'wp_slpa',
		N'wp_stgaudens'
	)

IF @version >= 11 AND SERVERPROPERTY('EngineEdition') <> 5
BEGIN
    update @Databases set ClusterName=cluster_name
    FROM sys.dm_hadr_cluster;
	SELECT @cluster=cluster_name
    FROM sys.dm_hadr_cluster
END


IF @version >= 11 AND @cluster is not null	-- We have a cluster, so let's check for availability configs
    BEGIN
	  UPDATE DBs
      SET	CurrentAvailabilityGroup = availability_groups.name,
			CurrentAvailabilityGroupRole = dm_hadr_availability_replica_states.role_desc
      FROM sys.databases databases
      INNER JOIN sys.availability_databases_cluster availability_databases_cluster ON databases.group_database_id = availability_databases_cluster.group_database_id
      INNER JOIN sys.availability_groups availability_groups ON availability_databases_cluster.group_id = availability_groups.group_id
      INNER JOIN sys.dm_hadr_availability_replica_states dm_hadr_availability_replica_states ON availability_groups.group_id = dm_hadr_availability_replica_states.group_id AND databases.replica_id = dm_hadr_availability_replica_states.replica_id
      INNER JOIN @Databases DBs on databases.name = DBs.DatabaseName
    END

    IF SERVERPROPERTY('EngineEdition') <> 5
    BEGIN
		UPDATE DBs
		SET CurrentDatabaseMirroringRole = UPPER(mirroring_role_desc)
      FROM sys.database_mirroring dbm
      INNER JOIN @Databases DBs on dbm.database_id = DBs.Database_id
    END

--For each database
DECLARE databases CURSOR STATIC FOR 
	SELECT d.Database_id, d.DatabaseName
	FROM @Databases AS d 
	WHERE ISNULL(d.CurrentDatabaseMirroringRole,'PRINCIPAL')='PRINCIPAL'
	AND ISNULL(d.CurrentAvailabilityGroupRole,'PRIMARY')='PRIMARY'

OPEN databases

WHILE 1 = 1
BEGIN

    FETCH NEXT FROM databases INTO @db_id, @db_name
	IF @@FETCH_STATUS <> 0 
		BREAK

	--Get number of tables in database
	SET @sql = 'SELECT @countTables = COUNT(*) FROM ' + QUOTENAME(@db_name) + '.sys.tables'
	EXEC sp_executesql @sql, N'@countTables int OUTPUT', @countTables = @tables_in_database OUTPUT

	--For each heap
	SET @sql = '
	DECLARE heaps CURSOR GLOBAL STATIC FOR
	 SELECT i.object_id 
	 FROM ' + QUOTENAME(DB_NAME(@db_id)) + '.sys.indexes AS i 
	  INNER JOIN ' + QUOTENAME(DB_NAME(@db_id)) + '.sys.objects AS o ON o.object_id = i.object_id
	 WHERE i.type_desc = ''HEAP''
	  AND o.type_desc = ''USER_TABLE''
	'
	EXEC(@sql)
	OPEN heaps
	SET @fragmented_heaps_in_database = 0
	SET @heaps_in_database = @@CURSOR_ROWS
	WHILE 1 = 1
	BEGIN
		FETCH NEXT FROM heaps INTO @object_id
		IF @@FETCH_STATUS <> 0 
			BREAK

		--Insert frag level for this heap into temp table
		INSERT INTO #heap_frag(object_id, page_count, record_count, forwarded_record_count, avg_page_space_used_in_percent, Max_Page_Space_Perc, Page_Space_Dev, avg_fragmentation_in_percent)
		SELECT P.object_id, P.page_count, P.record_count, P.forwarded_record_count, P.avg_page_space_used_in_percent
				,CASE 
					WHEN P.avg_record_size_in_bytes > 0
					THEN ((FLOOR(8060/P.avg_record_size_in_bytes) * P.avg_record_size_in_bytes) / 8060) * 100 
					ELSE 100
					END AS Max_Page_Space_Perc,
				CASE 
					WHEN P.avg_record_size_in_bytes > 0
					THEN ((FLOOR(8060/P.avg_record_size_in_bytes) * P.avg_record_size_in_bytes) / 8060) * 100 - P.avg_page_space_used_in_percent
					ELSE 100
					END AS Page_Space_Dev
				,CAST(avg_fragmentation_in_percent as tinyint)
		FROM sys.dm_db_index_physical_stats(@db_id, @object_id, 0, NULL, 'DETAILED') AS P
		WHERE P.alloc_unit_type_desc = 'IN_ROW_DATA'
		AND P.page_count > 0
	END

	CLOSE heaps
	DEALLOCATE heaps

	DECLARE heaps_with_frag CURSOR STATIC FOR 
		SELECT object_id, page_count, record_count, forwarded_record_count, 
			avg_page_space_used_in_percent, Max_Page_Space_Perc, Page_Space_Dev, avg_fragmentation_in_percent
		FROM #heap_frag

	OPEN heaps_with_frag
	WHILE 1 = 1
	BEGIN
		FETCH NEXT FROM heaps_with_frag INTO @object_id, @page_count, @record_count, @forwarded_record_count, 
			@avg_page_space_used_in_percent, @Max_Page_Space_Perc, @Page_Space_Dev, @avg_fragmentation_in_percent
		IF @@FETCH_STATUS <> 0 
			BREAK

		SET @heap_size_mb = (@page_count * 8) / 1024

		--Get table name and schema name
		SET @schema_name = OBJECT_SCHEMA_NAME(@object_id, @db_id)
		SET @table_name = OBJECT_NAME(@object_id, @db_id)

		--Calculate percentage for forwarded rows
		IF @record_count > 0
			SET @fwd_rows_percentage = (CAST(@forwarded_record_count AS decimal(29,2)) / CAST(@record_count AS decimal(29,2))) * 100
		ELSE
			SET @fwd_rows_percentage = 0
	  
		--Insert fragmentation statistics, if we are supposed to
		IF @report_type = 'all'
		BEGIN
			INSERT INTO ##frag_report(database_name, schema_name, table_name, size_in_mb, pages, rows_, forwarded_rows, fragmentation_level, avg_page_space_used_in_percent, Max_Page_Space_Perc, Page_Space_Dev, avg_fragmentation_in_percent)
			VALUES(@db_name, @schema_name, @table_name, @heap_size_mb, @page_count, @record_count, @forwarded_record_count, @fwd_rows_percentage, @avg_page_space_used_in_percent, @Max_Page_Space_Perc, @Page_Space_Dev, @avg_fragmentation_in_percent)
		END

		IF ((@avg_fragmentation_in_percent >= @fragmentation_level) OR (@Page_Space_Dev >= @free_space_level)) AND (@heap_size_mb BETWEEN @smallest_table_size_mb AND @largest_table_size_mb)
		BEGIN
			SET @fragmented_heaps_in_database += 1

			--Insert fragmentation statistics, if we are supposed to
			IF @report_type = 'fragmented_only'
			BEGIN
				INSERT INTO ##frag_report(database_name, schema_name, table_name, size_in_mb, pages, rows_, forwarded_rows, fragmentation_level, avg_page_space_used_in_percent, Max_Page_Space_Perc, Page_Space_Dev, avg_fragmentation_in_percent)
				VALUES(@db_name, @schema_name, @table_name, @heap_size_mb, @page_count, @record_count, @forwarded_record_count, @fwd_rows_percentage, @avg_page_space_used_in_percent, @Max_Page_Space_Perc, @Page_Space_Dev, @avg_fragmentation_in_percent)
			END

			--Construct the SQL command to rebuild heap
			SET @sql = 'ALTER TABLE ' + QUOTENAME(@db_name) + '.' + QUOTENAME(@schema_name) + '.' + QUOTENAME(@table_name) + ' REBUILD'

			--Output the ALTER TABLE command, if we are supposed to
			IF @print_sql_commands = 1
				RAISERROR(@sql, 10, 1) WITH NOWAIT

			--Execute the ALTER TABLE command, if we are supposed to
			IF @exec_sql_commands = 1
				EXEC(@sql)
		END

	END

	--Output database name and also tables, heaps and fragmented heaps in database
	SET @msg = 
		  '-- ' 
		+ RIGHT('          ' + CAST(@tables_in_database AS varchar(20)), 7) + ' tables'
		+ RIGHT('          ' + CAST(@heaps_in_database AS varchar(20)), 7) + ' heaps' 
		+ RIGHT('          ' + CAST(@fragmented_heaps_in_database AS varchar(20)), 7) + ' fragmented heaps in database '
		+ @db_name
		+ CHAR(13) + CHAR(10)

	RAISERROR(@msg, 10, 1) WITH NOWAIT

	CLOSE heaps_with_frag
	DEALLOCATE heaps_with_frag
	TRUNCATE TABLE #heap_frag

END

CLOSE databases
DEALLOCATE databases

IF @report_type IN('all', 'fragmented_only')
	SELECT database_name, schema_name, table_name, size_in_mb, pages, rows_, forwarded_rows, fragmentation_level, avg_page_space_used_in_percent, Max_Page_Space_Perc, Page_Space_Dev, avg_fragmentation_in_percent FROM ##frag_report

