@{
    EmailFrom = "jack@sqlserver-dba.com"
    EmailTo = @("jack@sqlserver-dba.com")
    SmtpServer = "mysmtp"
    SmtpPort = 25
    JobDurationThresholdPercent = 50
    JobDurationThresholdMinutes = 5
    LookbackHours = 26
    BaselineDays = 30
    RetentionDays = 30
    InstancesFile = "config\instances.txt"
    LogPath = "logs"
    Encrypt = $true
    TrustServerCertificate = $true
}
