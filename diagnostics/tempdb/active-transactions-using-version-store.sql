-----------------------------------------------------------------
-- active transactions using version store
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
	t.transaction_id
   ,t.name
   ,t.transaction_type
   ,t.transaction_state
   ,s.transaction_id
   ,s.session_id
   ,s.elapsed_time_seconds / 60 / 60.0 AS hours_tran_has_been_open
   ,des.login_time
   ,des.host_name
   ,des.program_name
   ,des.client_interface_name
   ,des.login_name
   ,des.status
   ,des.last_request_start_time
   ,des.last_request_end_time
   ,des.is_user_process
   ,des.transaction_isolation_level
   ,des.row_count
   ,DB_NAME(des.database_id) AS [db]
   ,des.open_transaction_count
   ,ib.*
FROM sys.dm_tran_active_transactions t
JOIN sys.dm_tran_active_snapshot_database_transactions s
	ON t.transaction_id = s.transaction_id
JOIN sys.dm_exec_sessions des
	ON DES.session_id = s.session_id
OUTER APPLY sys.dm_exec_input_buffer ( des.session_id , NULL ) AS ib
OPTION (RECOMPILE, MAXDOP 1);
