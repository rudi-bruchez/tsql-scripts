# ----------------------------------------------------------------
# Description: Generate a restore sequence for a given database
#
# rudi@babaluga.com, go ahead license
# ----------------------------------------------------------------

$directory = "C:\Users\Public\Documents\Backup"

Get-ChildItem -Path $directory\*.trn -File | ForEach-Object { 
    $cmd = "RESTORE LOG [mydb] FROM  DISK = N'$($_.FullName)' WITH  NORECOVERY, STATS = 5;"
    Out-File -FilePath $directory\restore.sql -InputObject $cmd -Encoding ASCII -Append
}

# or using dbatools

Get-ChildItem -Path $directory\*.trn -OutVariable backups
$backups | Restore-DbaDatabase -SqlInstance localhost -Continue