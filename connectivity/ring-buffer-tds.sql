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
    x.value('(//Record/ConnectivityTraceRecord/TdsDisconnectFlags/PhysicalConnectionIsKilled)[1]', 'int') AS [PhysicalConnectionIsKilled],
    x.value('(//Record/ConnectivityTraceRecord/TdsDisconnectFlags/DisconnectDueToReadError)[1]', 'int') AS [DisconnectDueToReadError],
    x.value('(//Record/ConnectivityTraceRecord/TdsDisconnectFlags/NetworkErrorFoundInInputStream)[1]', 'int') AS [NetworkErrorFoundInInputStream],
    x.value('(//Record/ConnectivityTraceRecord/TdsDisconnectFlags/ErrorFoundBeforeLogin)[1]', 'int') AS [ErrorFoundBeforeLogin],
    x.value('(//Record/ConnectivityTraceRecord/TdsDisconnectFlags/SessionIsKilled)[1]', 'int') AS [SessionIsKilled],
    x.value('(//Record/ConnectivityTraceRecord/TdsDisconnectFlags/NormalDisconnect)[1]', 'int') AS [NormalDisconnect]
    FROM (SELECT CAST (record as xml) FROM sys.dm_os_ring_buffers 
    WHERE ring_buffer_type = 'RING_BUFFER_CONNECTIVITY') AS R(x))
SELECT *
FROM cte
where RecordType = 'Error'
order by recordtime
