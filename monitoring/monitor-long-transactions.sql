USE [_dba]
GO

ALTER PROCEDURE [dbo].[monitorTransactions]
	@durationInMinutes int = 10,
	@mail_profile SYSNAME = '<profile>',
	@operator SYSNAME = N'<operator>'
AS BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @exception TABLE (content nvarchar(200) not null);

	INSERT INTO @exception
	VALUES
		('%some string 1%'),
		('%some string 2%');

	DECLARE @recipient NVARCHAR(MAX) = (
		SELECT email_address
		FROM msdb.dbo.sysoperators
		WHERE name = @operator
	)

	IF EXISTS (
		SELECT *
		FROM sys.dm_tran_active_transactions t
		JOIN sys.dm_tran_database_transactions dt ON t.transaction_id = dt.transaction_id
		JOIN sys.dm_tran_session_transactions st ON t.transaction_id = st.transaction_id
		JOIN sys.dm_exec_sessions se ON st.session_id = se.session_id
		JOIN sys.dm_exec_connections cn ON cn.session_id = se.session_id
		CROSS APPLY sys.dm_exec_sql_text(cn.most_recent_sql_handle) AS inputbuffer
		LEFT JOIN @exception e ON inputbuffer.text LIKE e.content
		WHERE inputbuffer.text IS NULL
		AND se.program_name NOT LIKE '%DatabaseMail%'
		AND DATEDIFF(MINUTE, t.transaction_begin_time, CURRENT_TIMESTAMP) > @durationInMinutes
		AND t.name NOT IN ('UPDATE STATISTICS', 'CheckDb')
		-- not at midnight, long process
		AND DATEPART(hour, CURRENT_TIMESTAMP) > 0
	) BEGIN
		DECLARE @body nvarchar(max)

		SELECT @body = N'<style>
			table {
				font-family: arial, sans-serif;
				border-collapse: collapse;
				width: 100%;
			}
			td, th {
				border: 1px solid #dddddd;
				text-align: left;
				padding: 8px;
			}
			</style><h1>long running transactions</h1><table>'
			+ N'<tr><th>transaction_id</th><th>name</th><th>begin_time</th><th>tran_elapsed_time_seconds</th><th>type</th><th>state</th><th>dtc state</th>
				<th>db</th><th>log_reuse_wait</th><th>rcsi</th><th>log_bytes_reserved</th><th>log_bytes_used</th><th>log_record_count</th><th>log size MB]</th>
				<th>log %</th><th>session_id</th><th>user tran</th><th>tran cnt</th><th>stmt nb</th><th>login_time</th><th>host_name</th>
				<th>program_name</th><th>login_name</th><th>status</th><th>inputbuffer</th><th>isolation_level</th></tr>'
			+ CAST((
				SELECT  
					t.transaction_id as [td],
					t.name as [td],
					FORMAT(t.transaction_begin_time, 'dd/MM/yyyy HH:mm') as [td],
					CAST(DATEDIFF(SECOND, t.transaction_begin_time, CURRENT_TIMESTAMP) as varchar(10)) as [td],
				 case t.transaction_type   
					  when 1 then 'Read/Write'   
					  when 2 then 'Read-Only'    
					  when 3 then 'System'   
					  when 4 then 'Distributed'  
					  else 'Unknown - ' + convert(varchar(20), transaction_type)     
				 end as [td],    
				 case t.transaction_state 
					  when 0 then 'Uninitialized' 
					  when 1 then 'Not Yet Started' 
					  when 2 then 'Active' 
					  when 3 then 'Ended (Read-Only)' 
					  when 4 then 'Committing' 
					  when 5 then 'Prepared' 
					  when 6 then 'Committed' 
					  when 7 then 'Rolling Back' 
					  when 8 then 'Rolled Back' 
					  else 'Unknown - ' + convert(varchar(20), transaction_state) 
				 end as [td], 
				 COALESCE(case t.dtc_state 
					  when 0 then NULL 
					  when 1 then 'Active' 
					  when 2 then 'Prepared' 
					  when 3 then 'Committed' 
					  when 4 then 'Aborted' 
					  when 5 then 'Recovered' 
					  else 'Unknown - ' + convert(varchar(20), dtc_state) 
				 end, 'none') as [td],
				 db.name as [td],
				 db.log_reuse_wait_desc as [td],
				 db.is_read_committed_snapshot_on as [td],
				 dt.database_transaction_log_bytes_reserved as [td],
				 dt.database_transaction_log_bytes_used as [td],
				 dt.database_transaction_log_record_count as [td],
				 CAST(logSize.cntr_value / 1000.0 as numeric(20, 2)) as [td],
				 logPercent.cntr_value as [td],
				 st.session_id as [td],
				 --st.transaction_descriptor as [td],
				 st.is_user_transaction as [td],
				 st.open_transaction_count as [td],
				 st.enlist_count as [td],
				 se.login_time as [td],
				 se.host_name as [td],
				 se.program_name as [td],
				 se.login_name as [td],
				 se.status as [td],
				 inputbuffer.text as [td],
				 CASE se.transaction_isolation_level
					WHEN 0 THEN 'Unspecified'
					WHEN 1 THEN 'Read Uncommitted'
					WHEN 2 THEN 'Read Committed'
					WHEN 3 THEN 'Repeatable Read'
					WHEN 4 THEN 'Serializable'
					WHEN 5 THEN 'Snapshot'
					ELSE CAST(se.transaction_isolation_level as varchar(50))
				 END as [td]
				FROM sys.dm_tran_active_transactions t
				JOIN sys.dm_tran_database_transactions dt ON t.transaction_id = dt.transaction_id
				JOIN sys.databases db ON dt.database_id = db.database_id
				JOIN sys.dm_os_performance_counters logSize ON db.name = logSize.instance_name
					AND logSize.object_name = 'SQLServer:Databases' AND logSize.counter_name = 'Log File(s) Size (KB)'
				JOIN sys.dm_os_performance_counters logPercent ON db.name = logPercent.instance_name
					AND logPercent.object_name = 'SQLServer:Databases' AND logPercent.counter_name = 'Percent Log Used'
				JOIN sys.dm_tran_session_transactions st ON t.transaction_id = st.transaction_id
				LEFT JOIN sys.dm_exec_sessions se ON st.session_id = se.session_id
				LEFT JOIN sys.dm_exec_connections cn ON cn.session_id = se.session_id
					OUTER APPLY sys.dm_exec_sql_text(cn.most_recent_sql_handle) AS inputbuffer
				WHERE se.program_name NOT LIKE '%DatabaseMail%'
				ORDER BY t.transaction_begin_time
			FOR XML RAW('tr'), ELEMENTS
			) AS NVARCHAR(MAX))
		+ N'</table>'

		EXEC msdb.dbo.sp_send_dbmail 
			@profile_name = @mail_profile,
			@recipients = @recipient,
			--@copy_recipients = 'rudi@babaluga.com',
			@subject = '[DATABASE] ALERT - transactions',   
			@body = @body,
			@body_format = 'HTML',
			@importance = 'high';
	END;
END;
