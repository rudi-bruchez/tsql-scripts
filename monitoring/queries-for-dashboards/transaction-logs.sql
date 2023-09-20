USE master;
go

CREATE OR ALTER PROCEDURE dbo.monitor_transaction_logs
AS BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SELECT 
        pc.instance_name as [db],
        CASE TRIM(pc.counter_name) 
            WHEN N'Data File(s) Size (KB)'  THEN 'Data File (MB)'
            WHEN N'Log File(s) Size (KB)'   THEN 'Log File (MB)'
            WHEN N'Percent Log Used'        THEN '% Log Used'
        END as [counter],
        pc.cntr_value /
            CASE TRIM(pc.counter_name) 
                WHEN N'Data File(s) Size (KB)'  THEN 1000
                WHEN N'Log File(s) Size (KB)'   THEN 1000
                WHEN N'Percent Log Used'        THEN 1
            END as [value]
    FROM sys.dm_os_performance_counters pc
    WHERE pc.object_name LIKE '%:Databases%'
    AND counter_name IN (
        N'Data File(s) Size (KB)',
        N'Log File(s) Size (KB)',
        N'Percent Log Used'
    )
    AND pc.instance_name NOT IN (
        N'model',
        N'mssqlsystemresource',
        N'_Total'
    )
    OPTION (MAXDOP 1);

END;
go

-- grant execute on dbo.monitor_transaction_logs to a monitoring user in the master database;
GRANT EXECUTE ON dbo.monitor_transaction_logs TO [monitoring_user];