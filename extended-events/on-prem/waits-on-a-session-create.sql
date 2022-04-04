-----------------------------------------------------------------
-- change the session_id, change the destination folder
-- use wait_completed if available
-- 
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

CREATE EVENT SESSION Waits_of_Particular_Session 
ON SERVER
ADD EVENT sqlserver.sql_statement_starting
(
	ACTION (sqlserver.session_id,
		sqlserver.sql_text,
		sqlserver.plan_handle)
	WHERE 
		sqlserver.session_id = 68
),
ADD EVENT sqlos.wait_info 
(
	ACTION (sqlserver.session_id,
		sqlserver.sql_text,
		sqlserver.plan_handle)
	WHERE 
		sqlserver.session_id = 68
),
ADD EVENT sqlos.wait_info_external
(
	ACTION (sqlserver.session_id,
		sqlserver.sql_text,
		sqlserver.plan_handle)
	WHERE 
		sqlserver.session_id = 68
),
ADD EVENT sqlserver.sql_statement_completed
(
	ACTION (sqlserver.session_id,
		sqlserver.sql_text,
		sqlserver.plan_handle)
	WHERE 
		sqlserver.session_id = 68
)
ADD TARGET package0.asynchronous_file_target
    (SET filename=N'D:\traces\Waits_of_Particular_Session.xel')
WITH (MAX_DISPATCH_LATENCY = 5 SECONDS, EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS, TRACK_CAUSALITY=ON)
GO

-------------------------------------------------
--             Start the Session               --
-------------------------------------------------
ALTER EVENT SESSION Waits_of_Particular_Session ON SERVER
STATE = START
GO

ALTER EVENT SESSION Waits_of_Particular_Session ON SERVER
STATE = STOP
GO
	
-------------------------------------------------
--               drop the session              --
-------------------------------------------------
DROP EVENT SESSION Waits_of_Particular_Session ON SERVER;

