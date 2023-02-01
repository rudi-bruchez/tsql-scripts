# ----------------------------------------------------------------
# Get all SQL Instances on a local server
# from https://stackoverflow.com/questions/60898551/powershell-get-sql-instance
#
# rudi@babaluga.com, go ahead license
# ----------------------------------------------------------------


$SQLInstances = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances

foreach ($sql in $SQLInstances) {
    [PSCustomObject]@{
        InstanceName = $sql
    }
}

Write-Host "The following SQL Instances were detected on the server $env:Computername $SQLInstances" -ForegroundColor Yellow

If ($SQLInstances -ne "MSSQLSERVER") {
    Write-Host "$($env:Computername)\$($SQLInstances)"
    $serverName =  "$($env:Computername)\$($SQLInstances)"
} Else {
    Write-Host "Standard SQL Instance was found, proceeding with the script."
    $ServerName = $env:Computername
}

Write-Host $serverName