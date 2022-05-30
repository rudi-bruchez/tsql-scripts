-----------------------------------------------------------------
-- get FlushCache long checkpoint message from the SQL Server
-- errorlog
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @errorlog TABLE (
	LogDate datetime2(0), 
	ProcessInfo sysname, 
	LogText nvarchar(2000)
	);

INSERT INTO @errorlog EXEC xp_readerrorlog 0, 1, N'FlushCache: cleaned up';
INSERT INTO @errorlog EXEC xp_readerrorlog 1, 1, N'FlushCache: cleaned up';
INSERT INTO @errorlog EXEC xp_readerrorlog 2, 1, N'FlushCache: cleaned up';
INSERT INTO @errorlog EXEC xp_readerrorlog 3, 1, N'FlushCache: cleaned up';
INSERT INTO @errorlog EXEC xp_readerrorlog 4, 1, N'FlushCache: cleaned up';
INSERT INTO @errorlog EXEC xp_readerrorlog 5, 1, N'FlushCache: cleaned up';

INSERT INTO @errorlog EXEC xp_readerrorlog 0, 1, N'average throughput';
INSERT INTO @errorlog EXEC xp_readerrorlog 1, 1, N'average throughput';
INSERT INTO @errorlog EXEC xp_readerrorlog 2, 1, N'average throughput';
INSERT INTO @errorlog EXEC xp_readerrorlog 3, 1, N'average throughput';
INSERT INTO @errorlog EXEC xp_readerrorlog 4, 1, N'average throughput';
INSERT INTO @errorlog EXEC xp_readerrorlog 5, 1, N'average throughput';

INSERT INTO @errorlog EXEC xp_readerrorlog 0, 1, N'last target outstanding';
INSERT INTO @errorlog EXEC xp_readerrorlog 1, 1, N'last target outstanding';
INSERT INTO @errorlog EXEC xp_readerrorlog 2, 1, N'last target outstanding';
INSERT INTO @errorlog EXEC xp_readerrorlog 3, 1, N'last target outstanding';
INSERT INTO @errorlog EXEC xp_readerrorlog 4, 1, N'last target outstanding';
INSERT INTO @errorlog EXEC xp_readerrorlog 5, 1, N'last target outstanding';

SELECT LogDate, 
	--ProcessInfo,
	DATENAME(weekday, LogDate) as [WeekDay],
	LogText
FROM @errorlog
ORDER BY LogDate DESC;
