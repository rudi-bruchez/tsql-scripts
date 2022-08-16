# get last SQL Server errors from application event log
Get-EventLog -LogName Application -Source MSSQLSERVER -EntryType Error -Newest 100