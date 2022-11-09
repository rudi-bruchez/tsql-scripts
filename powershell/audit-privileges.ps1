# ----------------------------------------------------------------
# Retrieves all privileges
# ** Work In Progress **
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

$srv.Logins | Format-Table -AutoSize -Property Name, DefaultDatabase, HasAccess, IsDisabled, Language, LoginType, State, WindowsLoginAccessType

foreach ($login in $srv.Logins) {
    # $login.EnumServerRoles() | Format-Table -AutoSize
    Write-Host '--------------------------------------------------' -ForegroundColor Cyan
    Write-Host '             ', $login.Name -ForegroundColor Cyan
    Write-Host '--------------------------------------------------' -ForegroundColor Cyan

    write-host 'Database mappings' -ForegroundColor Yellow
    $login.EnumDatabaseMappings() | Format-Table -AutoSize
    
    write-host 'Object permissions' -ForegroundColor Yellow
    $login.EnumObjectPermissions() | Format-Table -AutoSize

    foreach ($db in $login.EnumDatabaseMappings()) {
        if ($dbs -contains $db.DBName) {
            write-host "`n----- Database $($db.DBName) as user $($db.UserName) -----`n" -ForegroundColor DarkYellow
            $user = $srv.Databases[$db.DBName].Users[$db.UserName]
            write-host 'Database Role membership' -ForegroundColor Yellow
            # $user.EnumObjectPermissions() | Format-Table -AutoSize
            $user.EnumRoles() | Format-Table -AutoSize

            $currentdb = $srv.Databases[$db.DBName]
            foreach ($schema in $currentdb.Schemas) {
                write-host "`n----- Schema $($schema.Name) -----`n" -ForegroundColor DarkYellow
                $schema.EnumObjectPermissions() | Format-Table -AutoSize
            }
        }
    }

    write-host 'Server roles' -ForegroundColor Yellow
}

$srv.ConnectionContext.Disconnect();