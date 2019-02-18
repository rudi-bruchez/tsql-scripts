set-location E:\health\SQL_Server
$isodate=Get-Date -format s
$isodate=$isodate -replace(":","")
$basepath=(Get-Location -PSProvider FileSystem).ProviderPath
$instancepath=$basepath + "\config\instances.txt"
$outputfile="\logs\sql_server_health_daily_check_" + $isodate + ".html"
$outputfilefull = $basepath + $outputfile
 
$emailFrom = "jack@sqlserver-dba.com"
$emailTo = "jack@sqlserver-dba.com"
$subject = "SQL Server Health Daily Check"
$body = "SQL Server Health Daily Check"
$smtpServer = "mysmtp"
$filePath = ""
 
#invoke stylesheet
. .\modules\stylesheet.ps1
#intro smtp function
. .\modules\smtp.ps1

$dt = new-object "System.Data.DataTable"
foreach ($instance in get-content $instancepath)
{
$instance
$cn = new-object System.Data.SqlClient.SqlConnection "server=$instance;database=msdb;Integrated Security=sspi"
$cn.Open()
$sql = $cn.CreateCommand()
$sql.CommandText = "select @@servername as ServerName,
SERVERPROPERTY('ProductVersion') AS Version,
DB_NAME(mf.database_id) as [db_name],
suser_sname(da.owner_sid) as [db_owner],
type_desc,
CONVERT(sysname,DatabasePropertyEx(DB_NAME(mf.database_id),'Recovery')) AS [RecoveryMode],
CONVERT(sysname,DatabasePropertyEx(DB_NAME(mf.database_id),'IsAutoShrink')) AS [isAutoShrink],
mf.is_percent_growth AS [isPercentageGrowth],
mf.state_desc AS [db_state],
last_backup = (SELECT max(bus.backup_finish_date)
FROM msdb.dbo.backupset bus
INNER JOIN msdb.dbo.backupmediafamily bume ON bus.media_set_id = bume.media_set_id
WHERE bus.database_name = DB_NAME(mf.database_id))
,checkDBLocation = CASE WHEN (
select count(*) from sys.master_files as m1
where  m1.type_desc IN ('LOG')  and mf.type_desc IN ('ROWS')
AND substring(m1.physical_name,1,1) = substring(mf.physical_name,1,1)
AND m1.database_id = mf.database_id
) > 0 THEN '1'
ELSE '0'
END,
substring(physical_name,1,1)
from sys.master_files as mf
INNER JOIN sys.databases as da ON da.database_id = mf.database_id
"
$rdr = $sql.ExecuteReader()
$dt.Load($rdr)
$cn.Close()
}
 
$dt | select * -ExcludeProperty RowError, RowState, HasErrors, Name, Table, ItemArray | ConvertTo-Html -head $reportstyle -body "SQL Server Daily Health Check" | Set-Content $outputfilefull 
$filepath = $outputfilefull 
#Call smtp Function
sendEmail $emailFrom $emailTo $subject $body $smtpServer $filePath