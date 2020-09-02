-- https://docs.microsoft.com/fr-fr/archive/blogs/sqlserverfaq/troubleshooting-tempdb-growth-due-to-version-store-usage

SELECT 
    getdate() AS runtime, 
    SUM (user_object_reserved_page_count)*8 as usr_obj_kb,
    SUM (internal_object_reserved_page_count)*8 as internal_obj_kb,
    SUM (version_store_reserved_page_count)*8 as version_store_kb,
    SUM (unallocated_extent_page_count)*8 as freespace_kb,
    SUM (mixed_extent_page_count)*8 as mixedextent_kb
FROM sys.dm_db_file_space_usage;

-- I then used the DMV to track the Version Store cleanup Performance Counter or you can even use Perfmon to find out the same information. The DMV that I used was “sys.dm_os_performance_counters” and the counter name is “Version Cleanup rate (KB/s) “. This is a per second counter and is cumulative in nature. Capturing multiple snapshots of the cntr_value column value, I find that the value doesn’t go beyond 272696576.
-- The next thing that I would need to track is what is causing the version store usage. I used sys.dm_db_session_file_usage and sys.dm_db_task_space_usage to check if any sessions/tasks were currently accounting for the 18MB of version store usage that I see above. I found none. If you do find a Session ID with a high amount of internal_objects_alloc_page_count value from the aforementioned DMV outputs, then the next investigation point would be to find out what that session is doing. Next I went and tracked down all the transactions currently maintaining an active version store using the DMV sys.dm_tran_active_snapshot_database_transactions.
-- Query used:

select 
    GETDATE() AS runtime,
    a.*,
    b.kpid,
    b.blocked,
    b.lastwaittype,
    b.waitresource,
    db_name(b.dbid) as database_name,
    b.cpu,
    b.physical_io,
    b.memusage,
    b.login_time,
    b.last_batch,
    b.open_tran,
    b.status,
    b.hostname,
    b.program_name,
    b.cmd,
    b.loginame,
    request_id
from sys.dm_tran_active_snapshot_database_transactions a
join sys.sysprocesses b on a.session_id = b.spid

--  I then used the following query to retrieve the input buffer of the above transaction:

select GETDATE() AS runtime,b.spid,c.*
from sys.dm_tran_active_snapshot_database_transactions a
join sys.sysprocesses b on a.session_id = b.spid
cross apply sys.dm_exec_sql_text(sql_handle) c

--  You can use the T-SQL batch below to capture the above information from the DMVs in a loop:

