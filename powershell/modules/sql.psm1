function Invoke-SqlQuery {
    param (
        [Parameter(Mandatory=$true)][string]$ServerInstance,
        [string]$Database = "msdb",
        [Parameter(Mandatory=$true)][string]$Query,
        [bool]$Encrypt = $true,
        [bool]$TrustServerCertificate = $true
    )
    
    if (-not ('Microsoft.Data.SqlClient.SqlConnection' -as [type])) {
        try { Import-Module SqlServer -ErrorAction SilentlyContinue } catch { }
    }
    $connType = if ('Microsoft.Data.SqlClient.SqlConnection' -as [type]) {
        'Microsoft.Data.SqlClient.SqlConnection'
    } else {
        Write-Warning 'Microsoft.Data.SqlClient unavailable; falling back to System.Data.SqlClient'
        'System.Data.SqlClient.SqlConnection'
    }
    
    $cs = "Server=$ServerInstance;Database=$Database;Integrated Security=sspi;Connect Timeout=10;Encrypt=$Encrypt;TrustServerCertificate=$TrustServerCertificate"
    $dt = New-Object System.Data.DataTable
    $cn = $null
    
    try {
        $cn = New-Object $connType $cs
        $cn.Open()
        $cmd = $cn.CreateCommand()
        $cmd.CommandTimeout = 120
        $cmd.CommandText = $Query
        $rdr = $cmd.ExecuteReader()
        $dt.Load($rdr)
        if ($null -ne $rdr) { $rdr.Dispose() }
        return ,$dt # Note comma to prevent unrolling
    } finally {
        if ($null -ne $cn) { $cn.Dispose() }
    }
}
Export-ModuleMember -Function Invoke-SqlQuery
