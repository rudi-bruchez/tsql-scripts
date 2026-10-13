-----------------------------------------------------------------
-- IO latency per file over a sampling window (default 5 minutes),
-- instead of since the instance started.
--
-- Why a delta: sys.dm_io_virtual_file_stats accumulates since
-- startup. Right after a restart, a failover or a disk change,
-- the averages are dominated by the startup burst (buffer pool
-- warm-up, recovery, application catching up) and say nothing
-- about the current regime. Two snapshots and a difference do.
--
-- How to read the result:
-- - avg_write_ms / avg_read_ms is io_stall / number of IOs. The
--   stall counts the time an IO waits in the queue behind the
--   others, not only the device time. On data files, writes
--   (checkpoint, lazy writer) and read-ahead are posted in bursts,
--   so a high value there can be queueing, not a slow disk.
-- - The log file writes sequentially and synchronously: its
--   avg_write_ms is the closest thing to the device latency.
-- - avg_io_in_flight is the total stall divided by the window
--   (Little's law): the average number of IOs outstanding on that
--   file. High latency with a high value means a deep queue;
--   high latency with a value near zero means a few slow IOs.
-- - Always read avg_kb_per_* next to the latency: 4 ms for a
--   1 MB write is not 4 ms for an 8 KB one.
-- - Whether sessions actually wait on these IOs is answered by
--   the wait stats (PAGEIOLATCH_*, WRITELOG, IO_COMPLETION), not
--   by this query.
--
-- Read-only. The batch holds its session for the whole window.
-- Doesn't work on Azure SQL Database (no sys.master_files).
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @window char(8) = '00:05:00';   -- hh:mm:ss

IF OBJECT_ID('tempdb..#vfs_start') IS NOT NULL DROP TABLE #vfs_start;

SELECT  database_id, file_id, sample_ms,
        num_of_reads, num_of_bytes_read, io_stall_read_ms,
        num_of_writes, num_of_bytes_written, io_stall_write_ms
INTO    #vfs_start
FROM    sys.dm_io_virtual_file_stats(NULL, NULL);

WAITFOR DELAY @window;

WITH delta AS (
    SELECT  e.database_id,
            e.file_id,
            e.sample_ms            - s.sample_ms            AS elapsed_ms,
            e.num_of_reads         - s.num_of_reads         AS reads,
            e.num_of_bytes_read    - s.num_of_bytes_read    AS bytes_read,
            e.io_stall_read_ms     - s.io_stall_read_ms     AS stall_read_ms,
            e.num_of_writes        - s.num_of_writes        AS writes,
            e.num_of_bytes_written - s.num_of_bytes_written AS bytes_written,
            e.io_stall_write_ms    - s.io_stall_write_ms    AS stall_write_ms
    FROM    sys.dm_io_virtual_file_stats(NULL, NULL) AS e
    JOIN    #vfs_start AS s
            ON s.database_id = e.database_id AND s.file_id = e.file_id
)
SELECT  CAST(SYSDATETIME() AS datetime2(0))                         AS sample_end,
        d.elapsed_ms / 1000                                         AS window_s,
        LEFT(mf.physical_name, 2)                                   AS drive,
        DB_NAME(d.database_id)                                      AS database_name,
        mf.type_desc                                                AS file_type,
        mf.name                                                     AS logical_name,
        d.reads,
        CAST(d.stall_read_ms * 1.0 / NULLIF(d.reads, 0) AS decimal(10, 2))           AS avg_read_ms,
        CAST(d.bytes_read / 1024.0 / NULLIF(d.reads, 0) AS decimal(10, 1))           AS avg_kb_per_read,
        CAST(d.bytes_read / 1048576.0 / NULLIF(d.elapsed_ms / 1000.0, 0) AS decimal(10, 2)) AS read_mb_per_s,
        d.writes,
        CAST(d.stall_write_ms * 1.0 / NULLIF(d.writes, 0) AS decimal(10, 2))         AS avg_write_ms,
        CAST(d.bytes_written / 1024.0 / NULLIF(d.writes, 0) AS decimal(10, 1))       AS avg_kb_per_write,
        CAST(d.bytes_written / 1048576.0 / NULLIF(d.elapsed_ms / 1000.0, 0) AS decimal(10, 2)) AS write_mb_per_s,
        CAST((d.stall_read_ms + d.stall_write_ms) * 1.0 / NULLIF(d.elapsed_ms, 0) AS decimal(10, 2)) AS avg_io_in_flight,
        RIGHT(mf.physical_name, CHARINDEX(N'\', REVERSE(mf.physical_name)) - 1)     AS physical_file
FROM    delta AS d
JOIN    sys.master_files AS mf
        ON mf.database_id = d.database_id AND mf.file_id = d.file_id
WHERE   d.reads > 0 OR d.writes > 0
ORDER BY drive, database_name, file_type DESC, logical_name
OPTION (RECOMPILE, MAXDOP 1);

-- Per drive: what the volume served during the window.
WITH delta AS (
    SELECT  e.database_id, e.file_id,
            e.sample_ms            - s.sample_ms            AS elapsed_ms,
            e.num_of_reads         - s.num_of_reads         AS reads,
            e.num_of_bytes_read    - s.num_of_bytes_read    AS bytes_read,
            e.io_stall_read_ms     - s.io_stall_read_ms     AS stall_read_ms,
            e.num_of_writes        - s.num_of_writes        AS writes,
            e.num_of_bytes_written - s.num_of_bytes_written AS bytes_written,
            e.io_stall_write_ms    - s.io_stall_write_ms    AS stall_write_ms
    FROM    sys.dm_io_virtual_file_stats(NULL, NULL) AS e
    JOIN    #vfs_start AS s
            ON s.database_id = e.database_id AND s.file_id = e.file_id
)
SELECT  LEFT(mf.physical_name, 2)                                                    AS drive,
        CAST((SUM(d.reads) + SUM(d.writes)) * 1.0 / NULLIF(MAX(d.elapsed_ms) / 1000.0, 0) AS decimal(10, 1)) AS iops,
        CAST((SUM(d.bytes_read) + SUM(d.bytes_written)) / 1048576.0
             / NULLIF(MAX(d.elapsed_ms) / 1000.0, 0) AS decimal(10, 2))              AS mb_per_s,
        CAST(SUM(d.stall_read_ms) * 1.0 / NULLIF(SUM(d.reads), 0) AS decimal(10, 2))   AS avg_read_ms,
        CAST(SUM(d.stall_write_ms) * 1.0 / NULLIF(SUM(d.writes), 0) AS decimal(10, 2)) AS avg_write_ms
FROM    delta AS d
JOIN    sys.master_files AS mf
        ON mf.database_id = d.database_id AND mf.file_id = d.file_id
GROUP BY LEFT(mf.physical_name, 2)
ORDER BY drive
OPTION (RECOMPILE, MAXDOP 1);

DROP TABLE #vfs_start;
