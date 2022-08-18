# -----------------------------------------------------------------
#  
# rudi@babaluga.com, go ahead license
# -----------------------------------------------------------------

Get-Service -Name *sql* | Select-Object Name, DisplayName, StartType, Status

Get-WmiObject win32_service -Filter "name LIKE '%sql%'" | Select-Object Name, DisplayName, PathName, StartMode, StartName, Status