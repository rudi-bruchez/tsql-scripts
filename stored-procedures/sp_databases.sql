-----------------------------------------------------------------
-- Returns databases with size information
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

USE Master;
GO

CREATE OR ALTER PROCEDURE dbo.sp_databases
    @namePattern SYSNAME
AS BEGIN

    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SELECT 
        RTRIM(instance_name) as [database],
        CAST(MAX(CASE counter_name WHEN 'Data File(s) Size (KB)' THEN cntr_value ELSE 0 END) / 1024.0 as decimal(17,2)) as [data size (MB)],
        CAST(MAX(CASE counter_name WHEN 'Log File(s) Size (KB)' THEN cntr_value ELSE 0 END) / 1024.0 as decimal(17,2)) as [log size (MB)],
        MAX(CASE counter_name WHEN 'Percent Log Used' THEN cntr_value ELSE 0 END) as [Percent Log Used],
        CAST(MAX(CASE counter_name WHEN 'Log File(s) Used Size (KB)' THEN cntr_value ELSE 0 END) / 1024.0 as decimal(17,2)) as [log used (MB)],
        MIN(db.recovery_model_desc) as recovery_model,
        MIN(db.log_reuse_wait_desc) as log_reuse_wait 
    FROM sys.dm_os_performance_counters pc
    JOIN sys.databases db ON pc.instance_name = db.name
    WHERE object_name LIKE '%:Databases%'
    AND counter_name IN ('Log File(s) Size (KB)', 'Percent Log Used', 'Log File(s) Used Size (KB)', 'Data File(s) Size (KB)')
    AND instance_name NOT IN ('_Total', 'master', 'model', 'mssqlsystemresource')
    AND instance_name LIKE CONCAT('%', @namePattern, '%')
    GROUP BY instance_name
    ORDER BY instance_name
    OPTION (MAXDOP 1);

END;