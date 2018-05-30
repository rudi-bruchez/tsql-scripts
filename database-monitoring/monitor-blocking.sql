-----------------------------------------------------------------
-- Blocking detection.
-- To add into a scheduled SQL Server Agent job
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;

IF EXISTS (
	SELECT *
	FROM sys.dm_os_waiting_tasks ws
	WHERE ws.blocking_session_id > 0
	AND ws.wait_type LIKE 'LCK%'
	AND ws.wait_duration_ms > 20000
) BEGIN 
	DECLARE @body nvarchar(max)
	SET     @body = N'<style>
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
		</style><h1>blocage en cours</h1><table>'
		+ N'<tr><th>wait duration sec.</th><th>wait type</th><th>session id</th><th>blocking session id</th><th>commande</th></tr>'
		+ CAST((
		SELECT DISTINCT
			CAST(ws1.wait_duration_ms / 1000.0 as decimal(10, 2)) as td,
			ws1.wait_type as td,
			ws1.session_ID as td,
			ws1.blocking_session_id as td,
			'KILL ' + CAST(ses.session_id as varchar(20)) as td
		FROM sys.dm_os_waiting_tasks ws1
		JOIN sys.dm_exec_sessions ses ON ws1.blocking_session_id = ses.session_id
		WHERE ws1.blocking_session_id > 0
		AND ws1.blocking_session_id <> ws1.session_id
		AND ws1.wait_type LIKE 'LCK%'
		AND ses.session_id NOT IN (SELECT ws2.session_id FROM sys.dm_os_waiting_tasks ws2 WHERE ws2.blocking_session_id > 0)
		FOR XML RAW('tr'), ELEMENTS
		) AS NVARCHAR(MAX))
		+ N'</table>'

	EXEC msdb.dbo.sp_send_dbmail 
		@profile_name = 'PROFIL',
		@recipients = 'DESTINATAIRE',
		@copy_recipients = 'rudi@babaluga.com',
		@subject = '[DATABASE] ALERTE - blocage en cours',   
		@body = @body,
		@body_format = 'HTML',
		@importance = 'high';
END;