-----------------------------------------------------------------
-- generate code to change database owner to sa on all database
-- where it is not yet the case.
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------
SELECT 
	'ALTER AUTHORIZATION ON DATABASE::[' + name + '] TO [sa]'
FROM sys.databases
WHERE database_id > 4
AND owner_sid <> 0x01;
