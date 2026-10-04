# get last SQL Server Agent events from application event log
# the source is SQLSERVERAGENT for the default instance, SQLAgent$<instance name> for a named instance
Get-EventLog -LogName Application -Source SQLSERVERAGENT -Newest 100
