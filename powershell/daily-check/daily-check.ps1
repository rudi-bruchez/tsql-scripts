[CmdletBinding()]
param (
    [string]$Instance,
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"
$basepath = (Get-Item $PSScriptRoot).FullName
$configPath = Join-Path $basepath "config.psd1"

if (-not (Test-Path $configPath)) {
    Write-Error "Configuration file missing: $configPath" -ErrorAction Continue
    exit 2
}

try {
    $cfg = Import-PowerShellDataFile -Path $configPath
} catch {
    Write-Error "Failed to parse configuration file: $($_.Exception.Message)" -ErrorAction Continue
    exit 2
}

$requiredKeys = @('EmailFrom', 'EmailTo', 'SmtpServer', 'JobDurationThresholdPercent', 'JobDurationThresholdMinutes', 'InstancesFile', 'LogPath')
foreach ($k in $requiredKeys) {
    if (-not $cfg.ContainsKey($k)) { Write-Error "Missing config key: $k" -ErrorAction Continue; exit 2 }
}

if ($cfg.EmailTo -isnot [array] -or $cfg.EmailTo.Count -eq 0) { Write-Error "EmailTo must be a non-empty array" -ErrorAction Continue; exit 2 }
if ($null -eq ($cfg.JobDurationThresholdPercent -as [int]) -or ($cfg.JobDurationThresholdPercent -as [int]) -le 0) { Write-Error "JobDurationThresholdPercent must be a positive integer" -ErrorAction Continue; exit 2 }
if ($null -eq ($cfg.JobDurationThresholdMinutes -as [int]) -or ($cfg.JobDurationThresholdMinutes -as [int]) -le 0) { Write-Error "JobDurationThresholdMinutes must be a positive integer" -ErrorAction Continue; exit 2 }
if ($cfg.ContainsKey('Encrypt') -and $cfg.Encrypt -isnot [bool]) { Write-Error "Encrypt must be a boolean" -ErrorAction Continue; exit 2 }
if ($cfg.ContainsKey('TrustServerCertificate') -and $cfg.TrustServerCertificate -isnot [bool]) { Write-Error "TrustServerCertificate must be a boolean" -ErrorAction Continue; exit 2 }

$lookbackHours = if ($cfg.ContainsKey('LookbackHours')) { $cfg.LookbackHours } else { 26 }
$baselineDays = if ($cfg.ContainsKey('BaselineDays')) { $cfg.BaselineDays } else { 30 }
$retentionDays = if ($cfg.ContainsKey('RetentionDays')) { $cfg.RetentionDays } else { 30 }
$smtpPort = if ($cfg.ContainsKey('SmtpPort') -and $null -ne $cfg.SmtpPort) { $cfg.SmtpPort } else { 25 }
$isodate = (Get-Date).ToString("yyyyMMdd_HHmmss")

$instancesFile = if ([System.IO.Path]::IsPathRooted($cfg.InstancesFile)) { $cfg.InstancesFile } else { Join-Path $basepath $cfg.InstancesFile }

if (-not $Instance -and -not (Test-Path $instancesFile)) {
    Write-Error "Instances file missing: $($cfg.InstancesFile)" -ErrorAction Continue
    exit 2
}

$sqlFilePath = Join-Path $basepath "sql\job-exceptions.sql"
if (-not (Test-Path $sqlFilePath)) {
    Write-Error "Job exceptions SQL file missing: $sqlFilePath" -ErrorAction Continue
    exit 2
}

Import-Module (Join-Path $basepath "..\modules\sql.psm1") -Force
. (Join-Path $basepath "..\modules\stylesheet.ps1")
. (Join-Path $basepath "..\modules\smtp.ps1")

$instances = if ($Instance) { @($Instance) } else { Get-Content $instancesFile | Where-Object { $_ -match '\S' } }
$jobsQuery = Get-Content $sqlFilePath -Raw
$healthQuery = Get-Content (Join-Path $basepath "sql\database-health.sql") -Raw

$jobsParams = @{
    LookbackHours = $lookbackHours
    PercentThreshold = $cfg.JobDurationThresholdPercent
    MinutesThreshold = $cfg.JobDurationThresholdMinutes
    BaselineDays = $baselineDays
}

$dtHealth = New-Object System.Data.DataTable
$dtJobs = New-Object System.Data.DataTable
$unreachable = @()

$encrypt = if ($cfg.ContainsKey('Encrypt')) { $cfg.Encrypt } else { $true }
$trustCert = if ($cfg.ContainsKey('TrustServerCertificate')) { $cfg.TrustServerCertificate } else { $true }

foreach ($srv in $instances) {
    $cn = $null
    try {
        $cs = "Server=$srv;Database=master;Integrated Security=sspi;Connect Timeout=10;Encrypt=$encrypt;TrustServerCertificate=$trustCert"
        $cn = New-Object System.Data.SqlClient.SqlConnection $cs
        $cn.Open()
        
        $editionResult = Invoke-SqlQuery -ServerInstance $srv -Database "master" -Query "SELECT SERVERPROPERTY('EngineEdition') AS Edition" -Connection $cn
        if ($editionResult.Rows.Count -eq 0) { throw "No edition returned" }
        $isAzureDb = ($editionResult.Rows[0].Edition -in @(5,6,9,11,12))

        if (-not $isAzureDb) {
            $hRes = Invoke-SqlQuery -ServerInstance $srv -Database "master" -Query $healthQuery -Connection $cn
            if ($hRes.Rows.Count -gt 0) { $dtHealth.Merge($hRes) }

            $cn.ChangeDatabase("msdb")
            $jRes = Invoke-SqlQuery -ServerInstance $srv -Database "msdb" -Query $jobsQuery -Parameters $jobsParams -Connection $cn
            if ($jRes.Rows.Count -gt 0) { $dtJobs.Merge($jRes) }
        }
    } catch {
        Write-Error "Instance $srv encountered an error: $($_.Exception.Message)" -ErrorAction Continue
        $unreachable += [pscustomobject]@{ Instance = $srv; Error = $_.Exception.Message }
    } finally {
        if ($null -ne $cn) { $cn.Dispose() }
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
    foreach ($u in $unreachable) { $uHtml += "<li><strong>$([System.Net.WebUtility]::HtmlEncode($u.Instance))</strong>: $([System.Net.WebUtility]::HtmlEncode($u.Error))</li>" }
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
    
    $enableSsl = if ($cfg.ContainsKey('EnableSsl')) { $cfg.EnableSsl } else { $false }
    $cred = $null
    if ($cfg.ContainsKey('CredentialFile') -and (Test-Path (Join-Path $basepath $cfg.CredentialFile))) {
        $cred = Import-Clixml (Join-Path $basepath $cfg.CredentialFile)
    }
    try {
        Send-DailyCheckReport $cfg.EmailFrom $cfg.EmailTo $subject $fullHtml $cfg.SmtpServer $smtpPort $enableSsl $cred
    } catch {
        Write-Error "Failed to send report: $_" -ErrorAction Continue
        exit 2
    }
    Get-ChildItem $logDir -Filter "*.html" | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$retentionDays) } | Remove-Item -Force
}

if ($unreachable.Count -gt 0 -or $failures -gt 0) { exit 1 } else { exit 0 }
