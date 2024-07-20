$instance = "sql2022"
$passwords = Get-Content -Path "C:\temp\passwords.txt"

foreach ($password in $passwords) {
    $password = $password.Trim()
    $passwordSecure = ConvertTo-SecureString -String $password -AsPlainText -Force
    $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sa", $passwordSecure
    try {
        $connection = New-Object -TypeName Microsoft.SqlServer.Management.Common.ServerConnection -ArgumentList $instance, $credential
        $connection.Connect()
        Write-Host "Connected to $instance with password $password" -ForegroundColor Green
        break
    }
    catch {
        Write-Host "Failed to connect to $instance with password $password" -ForegroundColor Gray
    }
}
