//[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null
Import-Module SqlServer

$cn = new-object Microsoft.SqlServer.Management.Common.ServerConnection
$cn.ServerInstance = "MW10112\SQL2016"
$cn.LoginSecure    = $false
$cn.Login          = "sa"
$cn.Password       = "sa"

$srv = New-Object Microsoft.SqlServer.Management.Smo.Server($cn);  
$so = New-Object "Microsoft.SqlServer.Management.Smo.ScriptingOptions";
#$so.ScriptDrops = $TRUE;
$so.IncludeIfNotExists = $TRUE;
$so.AppendToFile = $FALSE
$so.ToFileOnly = $TRUE
$so.AnsiFile = $TRUE
$so.ConvertUserDefinedDataTypesToBaseType = $TRUE
$so.DriAll = $TRUE
$so.Permissions = $TRUE
$so.Triggers = $TRUE
$so.PrimaryObject = $TRUE
$so.Indexes = $TRUE
#$so.ClusteredIndexes = $TRUE
#$so.NonClusteredIndexes = $TRUE

#$path = "~/db_scripts/"
$path = "c:/temp/$(($cn.ServerInstance).replace('\','-'))_$((Get-Date –f 'yyyyMMdd-HHmm'))/"
if (!(Test-Path -path $path)) { Mkdir $path }

foreach ($db in $srv.Databases) {
	if (!$db.IsSystemObject) {
		$localPath = $path+$db.Name+"/"
		if (!(Test-Path -path ($localPath))) { Mkdir ($localPath) }
		
		if (!(Test-Path -path ($localPath+"tables/"))) { Mkdir ($localPath+"tables/") }
		foreach ($tbl in $db.tables) {
			if (!$tbl.IsSystemObject) {
				$so.FileName = $localPath+"tables/"+$tbl.Schema+"."+$tbl.Name+".tbl.sql"
				#Write-Host "écriture de $($tbl.Name) dans $($so.FileName)"
				$so.FileName
				$tbl.Script($so)
				#$tbl.Script($so) > [$tbl.Name].tbl.sql
			} # if (!$tbl.IsSystemObject)
		} # foreach $tbl
		if (!(Test-Path -path ($localPath+"procedures/"))) { Mkdir ($localPath+"procedures/") }
		foreach ($sp in $db.StoredProcedures) {
			if (!$sp.IsSystemObject) {
				$so.FileName = $localPath+"procedures/"+$sp.Schema+"."+$sp.Name+".sp.sql"
				$so.FileName
				$sp.Script($so)
			} # if (!$tbl.IsSystemObject)
		} # foreach $sp
		if (!(Test-Path -path ($localPath+"vues/"))) { Mkdir ($localPath+"vues/") }
		foreach ($vw in $db.Views) {
			if (!$vw.IsSystemObject) {
				$so.FileName = $localPath+"vues/"+$vw.Schema+"."+$vw.Name+".view.sql"
				$so.FileName
				$vw.Script($so)
			} # if (!$tbl.IsSystemObject)
		} # foreach $vw
	} # if ($db.IsSystemObject)
} # foreach $db
