-----------------------------------------------------------------
-- getting IO warnings form the errorlog files
-- code adapted from Glenn Berry https://glennsqlperformance.com/
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @errorlog TABLE (
	LogDate datetime2(0), 
	ProcessInfo sysname, 
	LogText nvarchar(2000)
	);

INSERT INTO @errorlog 
EXEC xp_readerrorlog 0, 1, N'taking longer than 15 seconds';

INSERT INTO @errorlog 
EXEC xp_readerrorlog 1, 1, N'taking longer than 15 seconds';

INSERT INTO @errorlog 
EXEC xp_readerrorlog 2, 1, N'taking longer than 15 seconds';

INSERT INTO @errorlog 
EXEC xp_readerrorlog 3, 1, N'taking longer than 15 seconds';

INSERT INTO @errorlog 
EXEC xp_readerrorlog 4, 1, N'taking longer than 15 seconds';

INSERT INTO @errorlog 
EXEC xp_readerrorlog 5, 1, N'taking longer than 15 seconds';

UPDATE @errorlog SET LogText = REPLACE(LogText, 'SQL Server has encountered ', '')
UPDATE @errorlog SET LogText = REPLACE(LogText, ' occurrence(s) of I/O requests taking longer than 15 seconds to complete on file ', '$')

SELECT LogDate, 
	--ProcessInfo,
	--LogText,
	TRY_CAST(LEFT(LogText, CHARINDEX('$', LogText)-1) as int) as occurrences,
	SUBSTRING(LogText, CHARINDEX('$', LogText) + 2, CHARINDEX(']', LogText) - CHARINDEX('$', LogText) - 2) as [file]
FROM @errorlog
ORDER BY LogDate DESC;
