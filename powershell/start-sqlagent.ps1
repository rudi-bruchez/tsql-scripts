# ----------------------------------------------------------------
# Check if the agent is running and if not, start it
#
# rudi@babaluga.com, go ahead license
# ----------------------------------------------------------------

Get-Service -Name "SQL*Agent*" | Where-Object {$_.Status -eq "Stopped"} | Start-Service

# to stop the service :
# Get-Service -Name "SQL*Agent*" | Where-Object {$_.Status -eq "Running"} | Stop-Service