########################################################################
# Deploy multiple subscribers usign backup initialization
# which is a good option
#
# rudi@babaluga.com, go ahead license
########################################################################

#Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
#Install-Module dbatools

# import module
. .\modules\replication.ps1

#---------- params -----------
$PublisherSQLInstance = "ASTROLAB" # server name
$BackupPathUNC = "\\machine\share\"
$Database = "my_db"
$SubscriptionDatabase = $Database
# list of SQL Server instances to deploy to
$SubscriberInstances = @('SUBSCRIBER1', 'SUBSCRIBER2')
$BackupFile = "$($Database)_SnapShot.bak"

$Cred = (Get-Credential sa)

# ------------- infos ---------------
$Distributor = Get-ReplDistributor($PublisherSQLInstance, $Cred)

# backup the publisher database
backup-DbaDatabase -SqlInstance $PublisherSQLInstance -SqlCredential $Cred -compressbackup `
    -copyonly -path $BackupPathUNC -Type Full -Database $Database `
    -FilePath $BackupFile -WithFormat

# get original files information
Get-DbaDbFile -SqlInstance $PublisherSQLInstance -Database $Database `
    | Select-Object TypeDescription, LogicalName, PhysicalName

# TODO
# $FileMapping = @{}

foreach($instance in $SubscriberInstances){
    
    # remove subscriber if exists
    Remove-ReplSubscription

    # restore database on the subscriber instance
    Restore-DbaDatabase -SqlInstance $instance -SqlCredential $Cred `
        -path "$($BackupPathUNC)$($BackupFile)" 
        -DatabaseName $SubscriptionDatabase -WithReplace `
        -FileMapping $FileMapping
    
    # rename the subscriber database if needed
    Rename-DbaDatabase -SqlInstance $instance -SqlCredential $Cred `
        -Database $SubscriptionDatabase -LogicalName "<DBN>_<FT>"
}