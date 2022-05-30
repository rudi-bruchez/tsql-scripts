-----------------------------------------------------------------
-- Lease expired on the primary replica, from errorlog message
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @errorlog TABLE (
	LogDate datetime2(0), 
	ProcessInfo sysname, 
	LogText nvarchar(2000)
	);

INSERT INTO @errorlog 
EXEC xp_readerrorlog 0, 1, N'and the Windows Server Failover Cluster has expired';

INSERT INTO @errorlog 
EXEC xp_readerrorlog 1, 1, N'and the Windows Server Failover Cluster has expired';

INSERT INTO @errorlog 
EXEC xp_readerrorlog 2, 1, N'and the Windows Server Failover Cluster has expired';

INSERT INTO @errorlog 
EXEC xp_readerrorlog 3, 1, N'and the Windows Server Failover Cluster has expired';

INSERT INTO @errorlog 
EXEC xp_readerrorlog 4, 1, N'and the Windows Server Failover Cluster has expired';

INSERT INTO @errorlog 
EXEC xp_readerrorlog 5, 1, N'and the Windows Server Failover Cluster has expired';

UPDATE @errorlog 
SET LogText = REPLACE(LogText, 
	' A connectivity issue occurred between the instance of SQL Server and the Windows Server Failover Cluster. To determine whether the availability group is failing over correctly, check the corresponding availability group resource in the Windows Server Failover Cluster.',
	'')

SELECT LogDate, 
	--ProcessInfo,
	DATENAME(weekday, LogDate) as [WeekDay],
	LogText
FROM @errorlog
ORDER BY LogDate DESC;
