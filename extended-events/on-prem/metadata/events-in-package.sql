DECLARE @package sysname = N'filestream';

SELECT
	p.name as package,
	o.name AS [event],
	o.description,
	ISNULL(o.capabilities, 0) AS [Capabilities],
	o.capabilities_desc AS [CapabilitiesDesc]
FROM sys.dm_xe_packages p
JOIN sys.dm_xe_objects o ON o.package_guid = p.guid
WHERE o.object_type = N'event' 
AND (o.capabilities & 1 = 0 
	OR o.capabilities IS NULL)
AND (p.capabilities & 1 = 0 OR p.capabilities IS NULL)
AND p.name = @package
ORDER BY o.name;