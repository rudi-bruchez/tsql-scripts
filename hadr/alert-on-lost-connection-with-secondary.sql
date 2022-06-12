-----------------------------------------------------------------
-- Sends an email where a "lost connection with secondary" 
-- message is seen in the errorlog.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SET NOCOUNT ON;

DECLARE @CheckPeriodInMinute int = 5
 
DECLARE @errorlog TABLE(
      LogDate datetime
    , ProcessInfo varchar(32)
    , Text varchar(max)
)
 
insert into @errorlog
exec sp_readerrorlog 0, 1, N'AlwaysOn Availability Groups connection with secondary database terminated for primary database';
 
IF EXISTS (
	SELECT * 
	FROM @errorlog
	WHERE LogDate > DATEADD(MINUTE, -@CheckPeriodInMinute, CURRENT_TIMESTAMP)
)
BEGIN
 
    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = 'PROFILE'
		, @subject = '[SQL] AlwaysOn AG lost connection to secondary database'
		, @recipients = 'rudi@babaluga.com'
		, @body = 'AlwaysOn Availability Groups on primary replica lost connection with secondary database in the last 5 minutes'
     
END