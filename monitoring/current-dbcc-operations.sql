-----------------------------------------------------------------
-- monitor current DBCC operations, like SHRINK or DBCC CHECKDB
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT der.session_id
	  ,der.start_time
	  ,der.status
	  ,der.command
	  ,DB_NAME(der.database_id) AS db
	  ,der.connection_id
	  ,der.blocking_session_id
	  ,der.wait_type
	  ,der.wait_time
	  ,der.last_wait_type
	  ,der.wait_resource
	  ,der.open_transaction_count
	  ,der.percent_complete
	  ,der.total_elapsed_time
	  ,der.dop
	  ,der.parallel_worker_count
	  ,der.is_resumable
	  ,dest.text
FROM sys.dm_exec_requests der
OUTER APPLY sys.dm_exec_sql_text(COALESCE(der.statement_sql_handle, der.sql_handle)) dest
WHERE der.command LIKE 'Dbcc%'
OPTION (RECOMPILE, MAXDOP 1);