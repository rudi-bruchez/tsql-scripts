-----------------------------------------------------------------
-- find triggers in the current database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	tr.Name,
	CASE tr.is_instead_of_trigger WHEN 1 THEN 'INSTEAD OF' ELSE 'AFTER' END as [type],
	CONCAT(QUOTENAME(SCHEMA_NAME(o.schema_id)), '.', QUOTENAME(o.name)) as [on],
	CASE o.type_desc 
		WHEN 'USER_TABLE' THEN 'TABLE'
		ELSE o.type_desc
	END as [obj],
	CAST(tr.create_date as datetime2(0)) as create_date,
	CAST(tr.modify_date as datetime2(0)) as modify_date,
	CASE tr.is_disabled WHEN 1 THEN 'disabled' ELSE 'enabled' END as [state],
	m.definition as [code],
	m.is_schema_bound as [schema_bound],
	m.uses_ansi_nulls as [ansi_nulls],
	m.uses_database_collation as [db_collation],
	CASE COALESCE(m.execute_as_principal_id, -10)
		WHEN -10 THEN 'CALLER'
		WHEN -2 THEN 'OWNER'
		ELSE (	SELECT name
				FROM sys.database_principals
				WHERE principal_id = m.execute_as_principal_id
		) 
	END as execute_as,
	NULLIF(CONCAT(ts.execution_count, ' since ', FORMAT(ts.cached_time, 'G')), ' since ') as execution_count,
	CAST(ts.last_execution_time as datetime2(0)) as last_execution,
	ts.last_worker_time,
	ts.last_logical_reads
FROM sys.triggers tr
JOIN sys.objects o ON tr.parent_id = o.object_id
JOIN sys.sql_modules m ON tr.object_id = m.object_id
LEFT JOIN sys.dm_exec_trigger_stats ts ON tr.object_id = ts.object_id 
	AND ts.database_id = DB_ID() 
WHERE tr.type = N'TR'
AND tr.is_ms_shipped = 0
ORDER BY [on]
OPTION (RECOMPILE, MAXDOP 1);