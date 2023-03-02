-----------------------------------------------------------------
-- Read the log for a given period and a given database
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @StartTime  as datetime2 = '2023-02-26 06:00:00';
DECLARE @EndTime    as datetime2 = '2023-02-26 11:00:00';
DECLARE @DatabaseName as sysname = 'PachadataFormation';

SELECT [DatabaseName]
      ,CONCAT([SchemaName], '.', [ObjectName], '.' + [IndexName] + CASE IndexType WHEN 1 THEN ' (CL)' WHEN 2 THEN ' (NC)' ELSE '' END) as [Object]
      ,[CommandType]
      --,[Command]
      ,CAST([StartTime] as datetime2(3)) as [StartTime]
      ,CAST([EndTime] as datetime2(3)) as [EndTime]
	  ,DATEDIFF(second, [StartTime], [EndTime]) as [Duration_sec]
	,ExtendedInfo.value('(/ExtendedInfo/PageCount)[1]', 'bigint') as [PageCount]
FROM _dba.dbo.CommandLog
WHERE DatabaseName = @DatabaseName
AND StartTime BETWEEN @StartTime AND @EndTime
ORDER BY [StartTime]
OPTION (RECOMPILE, MAXDOP 1);