-----------------------------------------------------------------
-- Find missing indexes in the Query Store
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

;WITH XMLNAMESPACES(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'),
qs AS (
    SELECT
        SUM(qrs.count_executions) AS executions,
        AVG(qrs.avg_logical_io_reads) AS avg_logical_io_reads,
        AVG(qrs.avg_cpu_time) / 1000 AS avg_cpu_time_ms,
        SUM(qsq.count_compiles) AS compiles,
        (SELECT TOP 1 qsqt.query_sql_text FROM sys.query_store_query_text qsqt
        WHERE qsqt.query_text_id = MAX(qsq.query_text_id)) AS query_text,
        TRY_CAST((SELECT TOP 1 qsp2.query_plan from sys.query_store_plan qsp2
        WHERE qsp2.query_id=qsq.query_id
        ORDER BY qsp2.plan_id DESC) as xml) AS query_plan,
        qsq.query_id,
        qsq.query_hash
    FROM sys.query_store_query qsq
    JOIN sys.query_store_plan qsp on qsq.query_id=qsp.query_id
    JOIN sys.query_store_runtime_stats qrs on qsp.plan_id = qrs.plan_id
    JOIN sys.query_store_runtime_stats_interval qsrsi on qrs.runtime_stats_interval_id=qsrsi.runtime_stats_interval_id
    WHERE
        qsp.query_plan like N'%<MissingIndexes>%'
        and qsrsi.start_time >= DATEADD(week, -1, SYSDATETIME())
    GROUP BY qsq.query_id, qsq.query_hash
), 
missingIndexes AS (
    SELECT
        executions,
        CAST(avg_logical_io_reads as NUMERIC(30, 2)) as avg_logical_io_reads,
        CAST(avg_cpu_time_ms as NUMERIC(30, 2)) as avg_cpu_time_ms,
        query_text,
        query_plan,
        query_id,
        [a].[value]('(MissingIndex/@Database)[1]', 'varchar(50)') AS [db],
        [a].[value]('(MissingIndex/@Schema)[1]', 'varchar(50)') AS [Schema],
        [a].[value]('(MissingIndex/@Table)[1]', 'varchar(50)') AS [Table],
        [a].[value]('(@Impact)[1]', 'NUMERIC(30, 2)') AS [Impact],
        [b].[value]('@Usage', 'varchar(50)') AS [Usage],
        [c].[value]('@Name', 'varchar(50)') AS [Column],
        [st].[value]('@StatementText', 'varchar(max)') AS [Statement]
    FROM qs
    CROSS APPLY qs.query_plan.[nodes]('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') [st]([st])
    CROSS APPLY [st].[nodes]('QueryPlan/MissingIndexes/MissingIndexGroup') [x]([a])
    CROSS APPLY [a].[nodes]('MissingIndex/ColumnGroup') [t]([b])
    CROSS APPLY [b].[nodes]('Column') [c]([c])
)
SELECT
    query_id,
    MIN(avg_logical_io_reads) as avg_logical_io_reads,
    MIN(avg_cpu_time_ms) as avg_cpu_time_ms,
    MIN(executions) as executions,
    MIN(CONCAT_WS('.', [db], [Schema], [Table])) as [Table],
    MIN([Impact]) as [Impact],
    STRING_AGG(IIF([Usage] = 'EQUALITY', [Column], NULL), ', ') as [Equality],
    STRING_AGG(IIF([Usage] = 'INEQUALITY', [Column], NULL), ', ') as [Inequality],
    STRING_AGG(IIF([Usage] = 'INCLUDE', [Column], NULL), ', ') as [Include],
    MIN(query_text) as query_text
FROM missingIndexes
GROUP BY query_id
ORDER BY executions DESC
OPTION (RECOMPILE, MAXDOP 1);
GO