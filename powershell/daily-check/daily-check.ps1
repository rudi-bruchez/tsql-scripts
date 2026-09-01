[CmdletBinding()]
param (
    [string]$Instance,
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"
$basepath = (Get-Item $PSScriptRoot).FullName
$configPath = Join-Path $basepath "config.psd1"

if (-not (Test-Path $configPath)) {
    $Host.UI.WriteErrorLine("Configuration file missing: $configPath")
    exit 2
}

try {
    $cfg = Import-PowerShellDataFile -Path $configPath
} catch {
    $Host.UI.WriteErrorLine("Failed to parse configuration file: $($_.Exception.Message)")
    exit 2
}

$requiredKeys = @('EmailFrom', 'EmailTo', 'SmtpServer', 'JobDurationThresholdPercent', 'JobDurationThresholdMinutes', 'InstancesFile', 'LogPath')
foreach ($k in $requiredKeys) {
    if (-not $cfg.ContainsKey($k)) { $Host.UI.WriteErrorLine("Missing config key: $k"); exit 2 }
}

$lookbackHours = if ($cfg.ContainsKey('LookbackHours')) { $cfg.LookbackHours } else { 26 }
$baselineDays = if ($cfg.ContainsKey('BaselineDays')) { $cfg.BaselineDays } else { 30 }
$retentionDays = if ($cfg.ContainsKey('RetentionDays')) { $cfg.RetentionDays } else { 30 }
$smtpPort = if ($cfg.ContainsKey('SmtpPort') -and $null -ne $cfg.SmtpPort) { $cfg.SmtpPort } else { 25 }
$isodate = (Get-Date).ToString("yyyyMMdd_HHmmss")

if (-not $Instance -and -not (Test-Path (Join-Path $basepath $cfg.InstancesFile))) {
    $Host.UI.WriteErrorLine("Instances file missing: $($cfg.InstancesFile)")
    exit 2
}

$sqlFilePath = Join-Path $basepath "sql\job-exceptions.sql"
if (-not (Test-Path $sqlFilePath)) {
    $Host.UI.WriteErrorLine("Job exceptions SQL file missing: $sqlFilePath")
    exit 2
}

Import-Module (Join-Path $basepath "modules\sql.psm1") -Force
. (Join-Path $basepath "modules\stylesheet.ps1")
. (Join-Path $basepath "modules\smtp.ps1")

$instances = if ($Instance) { @($Instance) } else { Get-Content (Join-Path $basepath $cfg.InstancesFile) | Where-Object { $_ -match '\S' } }
$jobsQueryRaw = Get-Content $sqlFilePath -Raw
$jobsQuery = $jobsQueryRaw -replace 'DECLARE\s+@LookbackHours\s+INT\s*=\s*\d+;', "DECLARE @LookbackHours INT = $lookbackHours;" `
                           -replace 'DECLARE\s+@PercentThreshold\s+INT\s*=\s*\d+;', "DECLARE @PercentThreshold INT = $($cfg.JobDurationThresholdPercent);" `
                           -replace 'DECLARE\s+@MinutesThreshold\s+INT\s*=\s*\d+;', "DECLARE @MinutesThreshold INT = $($cfg.JobDurationThresholdMinutes);" `
                           -replace 'DECLARE\s+@BaselineDays\s+INT\s*=\s*\d+;', "DECLARE @BaselineDays INT = $baselineDays;"

$dtHealth = New-Object System.Data.DataTable
$dtJobs = New-Object System.Data.DataTable
$unreachable = @()

$encrypt = if ($cfg.ContainsKey('Encrypt')) { $cfg.Encrypt } else { $true }
$trustCert = if ($cfg.ContainsKey('TrustServerCertificate')) { $cfg.TrustServerCertificate } else { $true }

foreach ($srv in $instances) {
    try {
        $editionResult = Invoke-SqlQuery -ServerInstance $srv -Database "master" -Query "SELECT SERVERPROPERTY('EngineEdition') AS Edition" -Encrypt $encrypt -TrustServerCertificate $trustCert
        if ($editionResult.Rows.Count -eq 0) { throw "No edition returned" }
        $isAzureDb = ($editionResult.Rows[0].Edition -in @(5,6,9,11,12))

        $sqlHealth = "SELECT @@servername as ServerName, SERVERPROPERTY('ProductVersion') AS Version, DB_NAME(mf.database_id) as [db_name], suser_sname(da.owner_sid) as [db_owner], type_desc, CONVERT(sysname,DatabasePropertyEx(DB_NAME(mf.database_id),'Recovery')) AS [RecoveryMode], CONVERT(sysname,DatabasePropertyEx(DB_NAME(mf.database_id),'IsAutoShrink')) AS [isAutoShrink], mf.is_percent_growth AS [isPercentageGrowth], mf.state_desc AS [db_state], last_backup = (SELECT max(bus.backup_finish_date) FROM msdb.dbo.backupset bus INNER JOIN msdb.dbo.backupmediafamily bume ON bus.media_set_id = bume.media_set_id WHERE bus.database_name = DB_NAME(mf.database_id)), CASE WHEN (select count(*) from sys.master_files as m1 where m1.type_desc IN ('LOG') and mf.type_desc IN ('ROWS') AND substring(m1.physical_name,1,1) = substring(mf.physical_name,1,1) AND m1.database_id = mf.database_id) > 0 THEN '1' ELSE '0' END as checkDBLocation, substring(physical_name,1,1) as DriveLetter FROM sys.master_files as mf INNER JOIN sys.databases as da ON da.database_id = mf.database_id"
        $hRes = Invoke-SqlQuery -ServerInstance $srv -Database "master" -Query $sqlHealth -Encrypt $encrypt -TrustServerCertificate $trustCert
        if ($hRes.Rows.Count -gt 0) { $dtHealth.Merge($hRes) }

        if (-not $isAzureDb) {
            $jRes = Invoke-SqlQuery -ServerInstance $srv -Database "msdb" -Query $jobsQuery -Encrypt $encrypt -TrustServerCertificate $trustCert
            if ($jRes.Rows.Count -gt 0) { $dtJobs.Merge($jRes) }
        }
    } catch {
        $Host.UI.WriteErrorLine("Instance $srv encountered an error: $($_.Exception.Message)")
        $unreachable += [pscustomobject]@{ Instance = $srv; Error = $_.Exception.Message }
    }
}

$htmlBody = "<h2>Database Health</h2>"
if ($dtHealth.Rows.Count -gt 0) {
    $htmlBody += ($dtHealth | Select-Object * -ExcludeProperty RowError, RowState, HasErrors, Name, Table, ItemArray | ConvertTo-Html -Fragment | Out-String)
} else { $htmlBody += "<p>No health data.</p>" }

$htmlBody += "<h2>Job Exceptions</h2>"
if ($dtJobs.Rows.Count -gt 0) {
    $jobsView = $dtJobs.DefaultView
    $jobsView.Sort = "RunDateTime DESC"
    $sortedJobs = $jobsView.ToTable()
    
    $jobsHtml = ($sortedJobs | Select-Object * -ExcludeProperty RowError, RowState, HasErrors, Name, Table, ItemArray | ConvertTo-Html -Fragment) -replace '<tr>(.*?)<td>Failed</td>', '<tr class="row-error">$1<td>Failed</td>' `
                          -replace '<tr>(.*?)<td>Canceled</td>', '<tr class="row-error">$1<td>Canceled</td>' `
                          -replace '<tr>(.*?)<td>Succeeded</td>', '<tr class="row-warn">$1<td>Succeeded</td>'
    $htmlBody += ($jobsHtml | Out-String)
} else { $htmlBody += "<p style='color:green'>No job anomalies detected.</p>" }

if ($unreachable.Count -gt 0) {
    $uHtml = "<h2>Instances with Errors</h2><ul>"
    foreach ($u in $unreachable) { $uHtml += "<li><strong>$($u.Instance)</strong>: $($u.Error)</li>" }
    $uHtml += "</ul>"
    $htmlBody = $uHtml + $htmlBody
}

$fullHtml = "<!DOCTYPE html><html><head><meta charset=`"utf-8`">$reportstyle<title>Daily Check</title></head><body>$htmlBody</body></html>"

$failures = 0
$anomalies = 0
if ($dtJobs.Rows.Count -gt 0) {
    $failures = @($dtJobs.Select("Status = 'Failed' OR Status = 'Canceled'")).Count
    $anomalies = $dtJobs.Rows.Count - $failures
}

$subject = if ($unreachable.Count -gt 0 -or $failures -gt 0) { "[ERRORS] SQL Server Daily Check" }
           elseif ($anomalies -gt 0) { "[WARN] SQL Server Daily Check" }
           else { "SQL Server Daily Check" }

if ($OutputPath) {
    $fullHtml | Set-Content $OutputPath -Encoding UTF8
    Write-Host "Saved to $OutputPath"
} else {
    $logDir = Join-Path $basepath $cfg.LogPath
    if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }
    $logFile = Join-Path $logDir "dailycheck_$isodate.html"
    $fullHtml | Set-Content $logFile -Encoding UTF8
    
    Send-DailyCheckReport $cfg.EmailFrom $cfg.EmailTo $subject $fullHtml $cfg.SmtpServer $smtpPort
    Get-ChildItem $logDir -Filter "*.html" | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$retentionDays) } | Remove-Item -Force
}

if ($unreachable.Count -gt 0 -or $failures -gt 0) { exit 1 } else { exit 0 }