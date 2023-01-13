-----------------------------------------------------------------
-- lists active running transactions
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

USE Master;
GO

CREATE OR ALTER PROCEDURE dbo.sp_activeTransactions
	@all bit = 0
AS BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT
		t.transaction_id,
		t.name,
		CAST(t.transaction_begin_time as datetime2(0)) as begin_time,
		DATEDIFF(SECOND, t.transaction_begin_time, CURRENT_TIMESTAMP) as tran_elapsed_time_seconds,
		 CASE t.transaction_type
			  WHEN 1 THEN 'Read/Write'
			  WHEN 2 THEN 'Read-Only'
			  WHEN 3 THEN 'System'
			  WHEN 4 THEN 'Distributed'
			  ELSE CONCAT('Unknown - ', transaction_type)
		 END AS [type],
		 CASE t.transaction_state
			  WHEN 0 THEN 'Uninitialized'
			  WHEN 1 THEN 'Not Yet Started'
			  WHEN 2 THEN 'Active'
			  WHEN 3 THEN 'Ended (Read-Only)'
			  WHEN 4 THEN 'Committing'
			  WHEN 5 THEN 'Prepared'
			  WHEN 6 THEN 'Committed'
			  WHEN 7 THEN 'Rolling Back'
			  when 8 THEN 'Rolled Back'
			  ELSE CONCAT('Unknown - ', transaction_state)
		 END AS [state],
		 case t.dtc_state
			  WHEN 0 THEN NULL
			  WHEN 1 THEN 'Active'
			  WHEN 2 THEN 'Prepared'
			  WHEN 3 THEN 'Committed'
			  WHEN 4 THEN 'Aborted'
			  WHEN 5 THEN 'Recovered'
			  ELSE CONCAT('Unknown - ', dtc_state)
		 END AS [dtc state],
		 db.name as db,
		 db.log_reuse_wait_desc as log_reuse_wait,
		 db.is_read_committed_snapshot_on as rcsi,
		 dt.database_transaction_log_bytes_reserved as log_bytes_reserved,
		 dt.database_transaction_log_bytes_used as log_bytes_used,
		 dt.database_transaction_log_record_count as log_record_count,
		 CAST(logSize.cntr_value / 1000.0 as numeric(20, 2)) as [log size MB],
		 logPercent.cntr_value as [log %],
		 st.session_id,
		 st.transaction_descriptor as [tran descr],
		 st.is_user_transaction as [user tran],
		 st.open_transaction_count as [tran cnt],
		 st.enlist_count as [stmt nb],
		 se.login_time,
		 se.host_name,
		 se.program_name,
		 se.login_name,
		 se.status,
		 inputbuffer.text as inputbuffer,
		 CASE se.transaction_isolation_level
			  WHEN 0 THEN 'Unspecified'
			  WHEN 1 THEN 'Read Uncommitted'
			  WHEN 2 THEN 'Read Committed'
			  WHEN 3 THEN 'Repeatable Read'
			  WHEN 4 THEN 'Serializable'
			  WHEN 5 THEN 'Snapshot'
			  ELSE CAST(se.transaction_isolation_level as varchar(50))
		 END as isolation_level
	FROM sys.dm_tran_active_transactions t
	JOIN sys.dm_tran_database_transactions dt ON t.transaction_id = dt.transaction_id
		AND dt.database_transaction_type = 1
	JOIN sys.databases db ON dt.database_id = db.database_id
	LEFT JOIN sys.dm_os_performance_counters logSize ON db.name = logSize.instance_name
		AND logSize.object_name LIKE '%:Databases' AND logSize.counter_name = 'Log File(s) Size (KB)'
	LEFT JOIN sys.dm_os_performance_counters logPercent ON db.name = logPercent.instance_name
		AND logPercent.object_name LIKE '%:Databases' AND logPercent.counter_name = 'Percent Log Used'
	JOIN sys.dm_tran_session_transactions st ON t.transaction_id = st.transaction_id
	LEFT JOIN sys.dm_exec_sessions se ON st.session_id = se.session_id
	LEFT JOIN sys.dm_exec_connections cn ON cn.session_id = se.session_id
		OUTER APPLY sys.dm_exec_sql_text(cn.most_recent_sql_handle) AS inputbuffer
	WHERE (se.session_id IS NOT NULL OR @all = 1)
	ORDER BY t.transaction_begin_time
	OPTION (MAXDOP 1);
END;
