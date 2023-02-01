-----------------------------------------------------------------
-- Set instance degree of parallelism (DOP) based on CPU count
-- and cost threshold for parallelism
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;

DECLARE @cpu smallint = (
	SELECT cpu_count / ISNULL(NULLIF(hyperthread_ratio, 0), 1) as cpu
	FROM sys.dm_os_sys_info
);

-- 8 cores or more, use 4 DOP, otherwise 2 DOP
-- ... as you wish.
DECLARE @dop NVARCHAR(20) = CASE 
	WHEN @cpu >= 8 THEN N'4'
	ELSE N'2'
END;

EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE;

-- we change the setting only if the default value was not changed
IF EXISTS (
	SELECT *
	FROM sys.configurations
	WHERE configuration_id = 1538 -- cost threshold for parallelism
	AND [value] = 5 -- default value
)
BEGIN
	EXEC sys.sp_configure N'cost threshold for parallelism', N'50';
END

-- we change the setting only if the default value was not changed
IF EXISTS (
	SELECT *
	FROM sys.configurations
	WHERE configuration_id = 1539 -- max degree of parallelism
	AND [value] = 0 -- default value
)
BEGIN
	EXEC sys.sp_configure N'max degree of parallelism', @dop; 
END

RECONFIGURE WITH OVERRIDE

EXEC sys.sp_configure N'show advanced options', N'0' RECONFIGURE WITH OVERRIDE;
GO

SELECT *
FROM sys.configurations
WHERE configuration_id IN (1538, 1539)

