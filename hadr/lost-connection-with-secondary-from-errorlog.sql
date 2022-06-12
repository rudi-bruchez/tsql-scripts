-----------------------------------------------------------------
-- Message from errorlog :
-- "AlwaysOn Availability Groups connection with secondary 
--  database terminated for primary database"
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @errorlog TABLE (
	LogDate datetime2(0), 
	ProcessInfo sysname, 
	LogText nvarchar(2000)
	);

INSERT INTO @errorlog EXEC xp_readerrorlog 0, 1, N'AlwaysOn Availability Groups connection with secondary database terminated for primary database';
INSERT INTO @errorlog EXEC xp_readerrorlog 1, 1, N'AlwaysOn Availability Groups connection with secondary database terminated for primary database';
INSERT INTO @errorlog EXEC xp_readerrorlog 2, 1, N'AlwaysOn Availability Groups connection with secondary database terminated for primary database';
INSERT INTO @errorlog EXEC xp_readerrorlog 3, 1, N'AlwaysOn Availability Groups connection with secondary database terminated for primary database';
INSERT INTO @errorlog EXEC xp_readerrorlog 4, 1, N'AlwaysOn Availability Groups connection with secondary database terminated for primary database';
INSERT INTO @errorlog EXEC xp_readerrorlog 5, 1, N'AlwaysOn Availability Groups connection with secondary database terminated for primary database';

SELECT LogDate, 
	--ProcessInfo,
	DATENAME(weekday, LogDate) as [WeekDay],
	MIN(LogText) as FirstLogText
FROM @errorlog
GROUP BY LogDate
ORDER BY LogDate DESC;