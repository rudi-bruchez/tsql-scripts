-----------------------------------------------------------------
-- List connections and their encryption settings
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT s.login_name, s.host_name, c.encrypt_option, COUNT(*) as nb_connections
FROM sys.dm_exec_connections c
JOIN sys.dm_exec_sessions s ON c.session_id = s.session_id
WHERE s.is_user_process = 1
AND c.net_transport = N'TCP'
GROUP BY s.login_name, s.host_name, c.encrypt_option
ORDER BY login_name, host_name 
OPTION (RECOMPILE, MAXDOP 1);