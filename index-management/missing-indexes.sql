-----------------------------------------------------------------
-- find missing indexes in the current database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

-------------------------------------------------------
DECLARE @table_name sysname = '%';
DECLARE @compressionType varchar(10) = 'ROW';
DECLARE @online bit = 1;
-------------------------------------------------------

SELECT	
	object_name(d.object_id) as [table], 
	COALESCE(d.equality_columns + ', ' + d.inequality_columns, d.equality_columns, d.inequality_columns) as [key],
	d.equality_columns,
	d.inequality_columns,
	d.included_columns,
	CAST(s.avg_total_user_cost as decimal(8,2)) as avg_total_user_cost,
	s.avg_user_impact,
	s.user_seeks + s.user_scans as usage,
	CAST(COALESCE(s.last_user_seek, s.last_user_scan) as datetime2(0)) as last_usage,

	-- DDL to create the index
	CONCAT('CREATE INDEX nix$', lower(object_name(object_id)), '$' 
	, REPLACE(REPLACE(REPLACE(COALESCE(equality_columns + ', ' + inequality_columns, equality_columns, inequality_columns), ']', ''), '[', ''), ', ', '_')
	, ' ON ', statement, ' (', COALESCE(equality_columns + ', ' + inequality_columns, equality_columns, inequality_columns) 
	, COALESCE(') INCLUDE (' + included_columns, '')
	, ') WITH (', IIF(@online = 1, 'ONLINE = ON, ', ''), 'DATA_COMPRESSION = ', @compressionType, ', SORT_IN_TEMPDB = ON)') as [DDL]

FROM	sys.dm_db_missing_index_details d 
JOIN sys.dm_db_missing_index_groups g ON d.index_handle = g.index_handle
JOIN sys.dm_db_missing_index_group_stats s ON g.index_group_handle = s.group_handle
WHERE database_id = db_id()
AND object_name(d.object_id) LIKE @table_name
ORDER BY usage DESC, object_name(d.object_id), s.user_seeks DESC, d.object_id
OPTION (RECOMPILE, MAXDOP 1);

