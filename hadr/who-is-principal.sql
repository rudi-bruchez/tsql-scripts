-----------------------------------------------------------------
-- lists availability groups, and what is the primary replica

-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT 
	ag.name as availability_group, 
	ags.primary_replica
FROM sys.dm_hadr_availability_group_states ags
JOIN sys.availability_groups ag ON ags.group_id = ag.group_id
-- WHERE ag.name = '<AG NAME>'
ORDER BY ag.name