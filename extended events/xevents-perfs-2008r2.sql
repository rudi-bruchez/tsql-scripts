-- search for events
select pkg.name as PackageName, obj.name as EventName
from sys.dm_xe_packages pkg
inner join sys.dm_xe_objects obj on pkg.guid = obj.package_guid
where obj.object_type = 'event'
and obj.name LIKE '%complet%'
order by 1, 2 

-- event columns
select * from sys.dm_xe_object_columns
where object_name = 'sql_statement_completed'

-- targets
select pkg.name as PackageName, obj.name as TargetName
from sys.dm_xe_packages pkg
inner join sys.dm_xe_objects obj on pkg.guid = obj.package_guid
where obj.object_type = 'target'
order by 1, 2 

-- let's go
CREATE EVENT SESSION [perfs] ON SERVER 
ADD EVENT sqlserver.rpc_completed (WHERE duration > 100000),
ADD EVENT sqlserver.sql_statement_completed (WHERE duration > 100000)
ADD TARGET package0.asynchronous_file_target(SET filename=N'perfs')
WITH (STARTUP_STATE=ON)
GO

-- existing sessions
SELECT *
FROM sys.dm_xe_sessions xe
JOIN sys.dm_xe_session_targets xet ON xe.[address] = xet.event_session_address
JOIN sys.dm_xe_session_events xee ON xe.[address] = xee.event_session_address