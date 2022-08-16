# Install-Module dbatools -force

$params = @{
  SqlInstance = 'SERVER'
  Database = '_DBA'
  ReplaceExisting = $true
  InstallJobs = $false
  LogToTable = $true
  # BackupLocation = 'C:\Data\Backup'
  CleanupTime = 65
  Verbose = $true
}

Install-DbaMaintenanceSolution @params