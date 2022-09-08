-----------------------------------------------------------------
-- get login timers from ring buffer 
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

;WITH cte AS
	(SELECT
	x.value('(//Record/ConnectivityTraceRecord/RecordType)[1]', 'varchar(30)') AS [RecordType], 
	x.value('(//Record/ConnectivityTraceRecord/RecordSource)[1]', 'varchar(30)') AS [RecordSource], 
	x.value('(//Record/ConnectivityTraceRecord/Spid)[1]', 'int') AS [Spid], 
	x.value('(//Record/ConnectivityTraceRecord/OSError)[1]', 'int') AS [OSError], 
	x.value('(//Record/ConnectivityTraceRecord/SniConsumerError)[1]', 'int') AS [SniConsumerError], 
	x.value('(//Record/ConnectivityTraceRecord/State)[1]', 'int') AS [State], 
	x.value('(//Record/ConnectivityTraceRecord/RecordTime)[1]', 'nvarchar(30)') AS [RecordTime],
	x.value('(//Record/ConnectivityTraceRecord/TdsBuffersInformation/TdsInputBufferError)[1]', 'int') AS [TdsInputBufferError],
	x.value('(//Record/ConnectivityTraceRecord/TdsBuffersInformation/TdsOutputBufferError)[1]', 'int') AS [TdsOutputBufferError],
	x.value('(//Record/ConnectivityTraceRecord/TdsBuffersInformation/TdsInputBufferBytes)[1]', 'int') AS [TdsInputBufferBytes],
	x.value('(//Record/ConnectivityTraceRecord/LoginTimers/TotalLoginTimeInMilliseconds)[1]', 'int') AS [TotalLoginTimeInMilliseconds],
	x.value('(//Record/ConnectivityTraceRecord/LoginTimers/LoginTaskEnqueuedInMilliseconds)[1]', 'int') AS [LoginTaskEnqueuedInMilliseconds],
	x.value('(//Record/ConnectivityTraceRecord/LoginTimers/NetworkWritesInMilliseconds)[1]', 'int') AS [NetworkWritesInMilliseconds],
	x.value('(//Record/ConnectivityTraceRecord/LoginTimers/NetworkReadsInMilliseconds)[1]', 'int') AS [NetworkReadsInMilliseconds],
	x.value('(//Record/ConnectivityTraceRecord/LoginTimers/SslProcessingInMilliseconds)[1]', 'int') AS [SslProcessingInMilliseconds],
	x.value('(//Record/ConnectivityTraceRecord/LoginTimers/SspiProcessingInMilliseconds)[1]', 'int') AS [SspiProcessingInMilliseconds],
	x.value('(//Record/ConnectivityTraceRecord/LoginTimers/LoginTriggerAndResourceGovernorProcessingInMilliseconds)[1]', 'int') AS [LoginTriggerAndResourceGovernorProcessingInMilliseconds]
	FROM (SELECT CAST (record as xml) FROM sys.dm_os_ring_buffers 
	WHERE ring_buffer_type = 'RING_BUFFER_CONNECTIVITY') AS R(x))
SELECT *
FROM cte
WHERE RecordType = 'LoginTimers'
ORDER BY recordtime
OPTION (RECOMPILE, MAXDOP 1);