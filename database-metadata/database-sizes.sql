SELECT 
	db,
	[Data File(s) Size (KB)] as [Data Size (MB)], 
	[Log File(s) Size (KB)] as [Log Size (MB)], 
	[Log File(s) Used Size (KB)] as [Log Used (MB)]
FROM (
	SELECT 
		instance_name as db,
		counter_name as [counter],
		CAST(cntr_value / 1000.0 as DECIMAL(18, 2)) as [value]
	FROM sys.dm_os_performance_counters pc
	WHERE pc.object_name LIKE '%:Databases%'
	AND counter_name IN ('Data File(s) Size (KB)', 'Log File(s) Size (KB)', 'Log File(s) Used Size (KB)')
	AND instance_name NOT IN ('_Total')
) as t
PIVOT (
	SUM([value])
	FOR [counter] IN ([Data File(s) Size (KB)], [Log File(s) Size (KB)], [Log File(s) Used Size (KB)])
) AS pt
WHERE db NOT IN ('master', 'model', 'mssqlsystemresource')
ORDER BY db
OPTION (RECOMPILE);

-- 2. used space in the current database
SELECT 
	SUM(
	((CAST(mf.size as bigint) * 8192) / 1024 / 1024) -
	(((mf.size * CONVERT(FLOAT, 8) - CAST(FILEPROPERTY(mf.name, 'SpaceUsed') AS FLOAT) * CONVERT(FLOAT, 8)))
/ 1024)) / 1024 AS 'spaced used GB'
FROM sys.master_files mf
JOIN sys.databases db ON mf.database_id = db.database_id
WHERE mf.database_id = DB_ID()
AND mf.type_desc = 'ROWS';

