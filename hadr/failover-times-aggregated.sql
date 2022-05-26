-----------------------------------------------------------------
-- Script to determine failover times in Availability Group 
-- adapted from https://dba.stackexchange.com/questions/131634/availability-group-how-to-determine-last-failover-time
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

;WITH cte_HADR AS (
    SELECT object_name, CONVERT(XML, event_data) AS data
    FROM sys.fn_xe_file_target_read_file('AlwaysOn*.xel', null, null, null)
    WHERE object_name = 'error_reported'
), 
cte_HADR2 as (
	SELECT data.value('(/event/@timestamp)[1]','datetime') AS [timestamp],
		   data.value('(/event/data[@name=''error_number''])[1]','int') AS [error_number],
		   data.value('(/event/data[@name=''message''])[1]','varchar(max)') AS [message]
	FROM cte_HADR
	WHERE data.value('(/event/data[@name=''error_number''])[1]','int') = 1480
)
SELECT 
	CAST(MIN([timestamp]) as datetime2(0)) as [when],
	DATENAME(weekday, MIN([timestamp])) as [DayOfWeek]
FROM cte_HADR2
GROUP BY DATEPART(year, [timestamp]), DATEPART(dayofyear, [timestamp]), DATEPART(hour, [timestamp])
ORDER BY [when]
OPTION (RECOMPILE, MAXDOP 1);
