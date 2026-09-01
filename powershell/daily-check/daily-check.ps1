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

$cfg = Import-PowerShellDataFile -Path $configPath
$requiredKeys = @('EmailFrom', 'EmailTo', 'SmtpServer', 'JobDurationThresholdPercent', 'JobDurationThresholdMinutes', 'InstancesFile', 'LogPath')
foreach ($k in $requiredKeys) {
    if (-not $cfg.ContainsKey($k)) { $Host.UI.WriteErrorLine("Missing config key: $k"); exit 2 }
}

$lookbackHours = if ($cfg.ContainsKey('LookbackHours')) { $cfg.LookbackHours } else { 26 }
$baselineDays = if ($cfg.ContainsKey('BaselineDays')) { $cfg.BaselineDays } else { 30 }
$retentionDays = if ($cfg.ContainsKey('RetentionDays')) { $cfg.RetentionDays } else { 30 }
$isodate = (Get-Date).ToString("yyyyMMdd_HHmmss")

if (-not $Instance -and -not (Test-Path (Join-Path $basepath $cfg.InstancesFile))) {
    $Host.UI.WriteErrorLine("Instances file missing: $($cfg.InstancesFile)")
    exit 2
}