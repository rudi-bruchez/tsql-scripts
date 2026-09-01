SELECT 
    @@servername as ServerName, 
    SERVERPROPERTY('ProductVersion') AS Version, 
    DB_NAME(mf.database_id) as [db_name], 
    SUSER_SNAME(da.owner_sid) as [db_owner], 
    type_desc, 
    CONVERT(sysname,DatabasePropertyEx(DB_NAME(mf.database_id),'Recovery')) AS [RecoveryMode], 
    CONVERT(sysname,DatabasePropertyEx(DB_NAME(mf.database_id),'IsAutoShrink')) AS [isAutoShrink], 
    mf.is_percent_growth AS [isPercentageGrowth], 
    mf.state_desc AS [db_state], 
    last_backup = (SELECT max(bus.backup_finish_date) FROM msdb.dbo.backupset bus INNER JOIN msdb.dbo.backupmediafamily bume ON bus.media_set_id = bume.media_set_id WHERE bus.database_name = DB_NAME(mf.database_id)), 
    CASE WHEN (select count(*) from sys.master_files as m1 where m1.type_desc IN ('LOG') and mf.type_desc IN ('ROWS') AND substring(m1.physical_name,1,1) = substring(mf.physical_name,1,1) AND m1.database_id = mf.database_id) > 0 THEN '1' ELSE '0' END as checkDBLocation, 
    substring(physical_name,1,1) as DriveLetter 
FROM sys.master_files as mf 
INNER JOIN sys.databases as da ON da.database_id = mf.database_id;
