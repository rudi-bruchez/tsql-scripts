-----------------------------------------------------------------
-- blocking sessions

-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SELECT session_id, blocking_session_id, STATUS, command, start_time, cpu_time, 
       reads, writes, wait_resource, wait_time, last_wait_type
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0
OR session_id IN (SELECT blocking_session_id 
                  FROM sys.dm_exec_requests 
                  WHERE blocking_session_id <> 0);