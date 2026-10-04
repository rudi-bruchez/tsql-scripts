Function Get-ReplDistributor {
    param(
        [string]$SqlInstance,
        [PSCredential]$Cred
    )
    $sql = "SELECT name FROM sys.databases WHERE is_distributor = 1;"
    $result = Invoke-DbaQuery -SqlInstance $SqlInstance -SqlCredential $Cred -Query $sql
    $result
}

Function Get-ReplSubscribers {
    param(
        [string]$SqlInstance,
        [PSCredential]$Cred,
        [string]$Distributor
    )
    $sql = "SELECT srv.srvname, sub.dest_db, sub.subscription_type, sub.status
    FROM $($Distributor).dbo.syssubscriptions sub
    JOIN $($Distributor).dbo.MSreplservers srv ON sub.srvid = srv.srvid;"
    $result = Invoke-DbaQuery -SqlInstance $SqlInstance -SqlCredential $Cred -Query $sql
    $result
}    

Function Remove-ReplSubscription {
    param(
        [string]$SqlInstance,
        [PSCredential]$Cred,
        [string]$Publisher,
        [string]$PublisherDb,
        [string]$Publication,
        [string]$Subscriber,
        [string]$SubscriberDb
    )
    
    # remove subscription on subscriber
    $sql = "EXEC $($SubscriberDb).dbo.sp_droppullsubscription @publisher = N'$($Publisher)', 
        @publisher_db = N'$($PublisherDb)', @publication = N'$($Publication)'"
    $result = Invoke-DbaQuery -SqlInstance $SqlInstance -SqlCredential $Cred -Query $sql

    # remove subscription on publisher
    # sp_dropsubscription runs at the publisher, in the publication database
    $sql = "EXEC $($PublisherDb).dbo.sp_dropsubscription @publication = N'$($Publication)', 
        @subscriber = N'$($Subscriber)', @destination_db = N'$($SubscriberDb)', @article = N'all'"
    $result = Invoke-DbaQuery -SqlInstance $Publisher -SqlCredential $Cred -Query $sql

}