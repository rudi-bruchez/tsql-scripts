function Invoke-SqlQuery {
    param (
        [string]$ServerInstance,
        [string]$Database = "msdb",
        [Parameter(Mandatory=$true)][string]$Query,
        [bool]$Encrypt = $true,
        [bool]$TrustServerCertificate = $true,
        [hashtable]$Parameters = @{},
        [System.Data.Common.DbConnection]$Connection = $null
    )
    
    # We accept the legacy System.Data.SqlClient driver because the probe for Microsoft.Data.SqlClient fails in PS7's private assembly load context.
    $connType = 'System.Data.SqlClient.SqlConnection'
    
    $dt = New-Object System.Data.DataTable
    $cn = $Connection
    $ownConnection = ($null -eq $cn)
    $cmd = $null
    
    try {
        if ($ownConnection) {
            $cs = "Server=$ServerInstance;Database=$Database;Integrated Security=sspi;Connect Timeout=10;Encrypt=$Encrypt;TrustServerCertificate=$TrustServerCertificate"
            $cn = New-Object $connType $cs
            $cn.Open()
        } else {
            if ($cn.State -ne 'Open') { $cn.Open() }
        }
        $cmd = $cn.CreateCommand()
        $cmd.CommandTimeout = 120
        $cmd.CommandText = $Query
        foreach ($p in $Parameters.GetEnumerator()) {
            [void]$cmd.Parameters.AddWithValue("@$($p.Key)", $p.Value)
        }
        $rdr = $cmd.ExecuteReader()
        $dt.Load($rdr)
        if ($null -ne $rdr) { $rdr.Dispose() }
        return ,$dt # Note comma to prevent unrolling
    } finally {
        if ($null -ne $cmd) { $cmd.Dispose() }
        if ($ownConnection -and $null -ne $cn) { $cn.Dispose() }
    }
}
Export-ModuleMember -Function Invoke-SqlQuery
