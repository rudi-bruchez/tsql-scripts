# ----------------------------------------------------------------
# Retreives all privileges in a database
# can be redirected to a file by calling it with > filename.txt
#
# rudi@babaluga.com, go ahead license
# ----------------------------------------------------------------

# Install-Module -Name SqlServer -AllowPrerelease -force
Import-Module -name SqlServer

# ---------------------------------------------------------------------- 
# ------------                   parameters                 ------------
$servername = "myserver"
$dbs = @("db1","db2")
$login = ""
$password = ""
# ---------------------------------------------------------------------- 

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null

$srv = New-Object Microsoft.SqlServer.Management.Smo.Server $servername
$srv.ConnectionContext.NonPooledConnection = $true;
$srv.ConnectionContext.ConnectTimeout = 0;
$srv.ConnectionContext.StatementTimeout = 0;

$srv.ConnectionContext.LoginSecure = $false;
$srv.ConnectionContext.set_Login($login);
$srv.ConnectionContext.set_Password($password);
$srv.ConnectionContext.DatabaseName = "master";

$srv.ConnectionContext.Connect()

foreach ($db in $srv.Databases) {
    if ($dbs -contains $db.Name) {

        Write-Output '--------------------------------------------------' 
        Write-Output "            DATABASE [$($db.Name)]                "
        Write-Output '--------------------------------------------------' 

        # Write-Output 'Object permissions' -ForegroundColor Yellow
        # $db.EnumObjectPermissions() | Format-Table -AutoSize

        foreach ($schema in $db.Schemas) {
            if ($schema.EnumObjectPermissions().Count -gt 0 -and $schema.Name -ne 'sys' -and $schema.Name -ne 'INFORMATION_SCHEMA') {
                Write-Output "`n----- Schema [$($schema.Name)] -----" 
                $schema.EnumObjectPermissions() | Format-Table -AutoSize -Property Grantee, PermissionType, PermissionState, Grantor
            }
        }
        
        foreach ($table in $db.Tables) {
            if ($table.EnumObjectPermissions().Count -gt 0 -and $table.IsSystemObject -eq $false) {
                Write-Output "`n----- table [$($table.Name)] -----" 
                $table.EnumObjectPermissions() | Format-Table -AutoSize -Property Grantee, PermissionType, PermissionState, Grantor
            }
        }
        
        foreach ($view in $db.Views) {
            if ($view.EnumObjectPermissions().Count -gt 0 -and $view.IsSystemObject -eq $false) {
                Write-Output "`n----- view [$($view.Name)] -----" 
                $view.EnumObjectPermissions() | Format-Table -AutoSize -Property Grantee, PermissionType, PermissionState, Grantor
            }
        }
    }
}

$srv.ConnectionContext.Disconnect();
