-----------------------------------------------------------------
-- returns detailed usage of SQL Server memory
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

USE Master;
GO

CREATE OR ALTER PROCEDURE sp_memorystatus
AS 
/*
EXEC sp_memorystatus
*/
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    ;WITH cte AS (
        SELECT 
            'Physical OS memory (MB)' AS [counter],
            total_physical_memory_kb / 1024 AS [Value],
            10 as sort
        FROM sys.dm_os_sys_memory

        UNION ALL 

        SELECT name, value_in_use, 20 as sort
        FROM sys.configurations 
        WHERE name LIKE 'max server memory%'

        UNION ALL 

        SELECT N'Buffer cache hit ratio' AS [counter], 
            CAST((ratio.cntr_value * 1.0 / base.cntr_value) * 100.0 AS NUMERIC(5, 2)) as [Value],
            30 as sort
        FROM sys.dm_os_performance_counters ratio WITH (READUNCOMMITTED)
        JOIN sys.dm_os_performance_counters base  WITH (READUNCOMMITTED) 
            ON ratio.object_name = base.object_name
        WHERE RTRIM(ratio.object_name) LIKE N'%:Buffer Manager'
        AND ratio.counter_name = N'Buffer cache hit ratio'
        AND base.counter_name = N'Buffer cache hit ratio base'

        UNION ALL

        SELECT 
            RTRIM(counter_name) as counter_name, 
            cntr_value AS [value],
            40 as sort
        FROM sys.dm_os_performance_counters WITH (READUNCOMMITTED)
        WHERE (RTRIM([object_name]) LIKE N'%:Buffer Manager' -- Handle named instances
            AND counter_name IN (N'Page life expectancy'))
        OR (RTRIM([object_name]) LIKE N'%:Plan Cache' AND instance_name = N'_Total' AND counter_name = N'Cache Object Counts')

        UNION ALL

        SELECT 
            REPLACE(counter_name, '(KB)', '(MB)') as [counter],
            CAST(cntr_value / 1000.0 as DECIMAL(20, 2)) as [value],
            CASE counter_name
                WHEN N'Target Server Memory (KB)' THEN 24
                WHEN N'Total Server Memory (KB)' THEN 25
                ELSE 50
            END as sort
        FROM sys.dm_os_performance_counters WITH (READUNCOMMITTED)
        WHERE object_name LIKE '%:Memory Manager%'
        AND counter_name IN (
            N'Stolen Server Memory (KB)',
            N'Log Pool Memory (KB)',
            N'Target Server Memory (KB)',
            N'Total Server Memory (KB)',
            N'Database Cache Memory (KB)',
            N'Maximum Workspace Memory (KB)',
            N'Free Memory (KB)',
            N'SQL Cache Memory (KB)',
            N'Optimizer Memory (KB)',
            N'Reserved Server Memory (KB)',
            N'Lock Memory (KB)',
            N'Granted Workspace Memory (KB)',
            N'Connection Memory (KB)'
        )
    )
    SELECT 
        [counter],
        [value]
    FROM cte
    ORDER BY sort
    OPTION (MAXDOP 1);

    DECLARE @clecks TABLE (
        ClerkType nvarchar(60) not null primary key,
        NiceName varchar(100) not null
    )

    INSERT INTO @clecks
    VALUES 
    (N'MEMORYCLERK_SQLBUFFERPOOL', 'BUFFER POOL'),
    (N'CACHESTORE_SQLCP', 'PLAN CACHE'),
    (N'CACHESTORE_PHDR', 'COMPILATION PARSING'),
    (N'USERSTORE_DBMETADATA', 'METADATA'),
    (N'MEMORYCLERK_SOSNODE', 'SQL OS INTERNAL'),
    (N'CACHESTORE_OBJCP', 'PROC CACHE'),
    (N'MEMORYCLERK_SQLCLR', '.NET CLR'),
    (N'MEMORYCLERK_SQLSTORENG', 'STORAGE ENGINE INTERNAL'),
    (N'USERSTORE_TOKENPERM', 'SECURITY CONTEXT, LOGIN, USER, PERMISSION, AND AUDIT'),
    (N'CACHESTORE_SYSTEMROWSET', 'TRANSACTION LOGGING AND RECOVERY'),
    (N'OBJECTSTORE_LOCK_MANAGER', 'LOCK_MANAGER'),
    (N'USERSTORE_SCHEMAMGR', 'TABLES AND OBJECTS METADATA'),
    (N'MEMORYCLERK_SQLTRACE', 'SQL TRACE / PROFILER'),
    (N'MEMORYCLERK_SQLLOGPOOL', 'LOG POOL'),
    (N'MEMORYCLERK_SQLGENERAL', 'SQL GENERAL'),
    (N'MEMORYCLERK_XE', 'XEVENTS'),
    (N'USERSTORE_OBJPERM', 'OBJECT SECURITY/PERMISSION'),
    (N'MEMORYCLERK_XTP', 'IN-MEMORY OLTP'),
    (N'MEMORYCLERK_SQLCONNECTIONPOOL', 'CONNECTION POOL'),
    (N'MEMORYCLERK_SQLOPTIMIZER', 'OPTIMIZER')
    OPTION (MAXDOP 1);

    SELECT TOP(20) 
        c.[type] AS [Clerk],
        MIN(n.NiceName) as [Description],
    SUM(c.pages_kb) / 1024 AS [Size_Mb],
    SUM(c.virtual_memory_reserved_kb)  / 1024 as virtual_memory_reserved_MB,
    SUM(c.virtual_memory_committed_kb)  / 1024 as virtual_memory_committed_MB
    FROM sys.dm_os_memory_clerks c WITH (READUNCOMMITTED)
    LEFT JOIN @clecks n ON c.[type] = n.ClerkType
    GROUP BY c.[type]
    ORDER BY SUM(c.pages_kb) DESC
    OPTION (MAXDOP 1);
END;
GO
