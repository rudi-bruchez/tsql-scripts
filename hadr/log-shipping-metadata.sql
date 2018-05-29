-----------------------------------------------------------------
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

-- secondary
SELECT sd.secondary_database, 
       s.primary_server, 
       s.primary_database, 
       s.backup_source_directory, 
       s.backup_destination_directory,
       sd.last_restored_file,
       sd.last_restored_date, 
       s.last_copied_file, 
       s.last_copied_date
FROM msdb.dbo.log_shipping_secondary s
JOIN msdb.dbo.log_shipping_secondary_databases sd 
       ON s.secondary_id = sd.secondary_id;
       
-- principal
SELECT
       primary_database,
       backup_directory,
       backup_share,
       last_backup_file,
       last_backup_date
FROM msdb.dbo.log_shipping_primary_databases;