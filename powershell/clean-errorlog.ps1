# clean ERRORLOG files in the current directory, and
# generate cleaned files with ".cleaned" extension

Get-ChildItem "." -Filter ERRORLOG* | 
Foreach-Object {

    Get-Content $_.FullName | `
    Where-Object {$_ -notmatch 'Log was backed up' `
        -and $_ -notmatch 'BACKUP DATABASE WITH DIFFERENTIAL successfully processed' `
        -and $_ -notmatch 'Database differential changes were backed up' `
        -and $_ -notmatch 'found 0 errors and repaired 0 errors' `
        -and $_ -notmatch 'BACKUP DATABASE successfully processed' `
        -and $_ -notmatch 'finished without errors' `
        -and $_ -notmatch 'changed from 1 to 1.' `
        -and $_ -notmatch 'changed from 0 to 0.' `
        -and $_ -notmatch 'Database backed up.'} `
    | Set-Content "$($_.FullName).cleaned"
}

