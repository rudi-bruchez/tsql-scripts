########################################################################
# Extacts all system stored procedures codes using SMO
#
# rudi@babaluga.com, go ahead license
########################################################################

# Install-Module -Name SqlServer
Import-Module SqlServer

$cn = new-object Microsoft.SqlServer.Management.Common.ServerConnection
# ---------------------------------------------------------------------- 
# ------------                   parameters                 ------------
$cn.ServerInstance = ".\SQL2019"  # server name
$cn.LoginSecure    = $true       # set to true for Windows Authentication 
# $cn.Login          = "sa"
# $cn.Password       = "sa"
$destinationFolder = "c:/temp/"     # destination folder
# ---------------------------------------------------------------------- 

$srv = New-Object Microsoft.SqlServer.Management.Smo.Server($cn);  
$so = New-Object "Microsoft.SqlServer.Management.Smo.ScriptingOptions";
#$so.ScriptDrops = $TRUE;
$so.IncludeIfNotExists = $TRUE;
$so.AppendToFile = $FALSE
$so.ToFileOnly = $TRUE
$so.AnsiFile = $TRUE
$so.ConvertUserDefinedDataTypesToBaseType = $TRUE
$so.PrimaryObject = $TRUE

$path = "$($destinationFolder)$(($srv.Name).replace('\','-'))/"

if (!(Test-Path -path $path)) { Mkdir $path }

$db = $srv.Databases["master"]

foreach ($sp in $db.StoredProcedures) {
	if ($sp.IsSystemObject && $sp.Schema -eq "sys") {
		$so.FileName = "$($path)$($sp.Name).sql"
		$so.FileName
		$sp.Script($so)
	} # if (!$tbl.IsSystemObject)
} # foreach $sp
