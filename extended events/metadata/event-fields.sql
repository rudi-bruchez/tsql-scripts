SELECT
	p.name as package,
	o.name AS [event],
	c.name AS [field],
	c.type_name as [type],
	c.description AS [Description]
FROM sys.dm_xe_packages p
JOIN sys.dm_xe_objects o ON o.package_guid = p.guid
JOIN sys.dm_xe_object_columns c ON c.object_name = o.name AND c.object_package_guid = o.package_guid
--INNER JOIN sys.dm_xe_packages AS typepackage ON columns.type_package_guid = typepackage.guid
WHERE c.column_type='data'
AND o.object_type = N'event' 
 AND (o.capabilities & 1 = 0 OR o.capabilities IS NULL)
 AND (p.capabilities & 1 = 0 OR p.capabilities IS NULL)
 OPTION (RECOMPILE, MAXDOP 1);
