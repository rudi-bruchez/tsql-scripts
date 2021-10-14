-----------------------------------------------------------------
-- follow queries run by a specific session_id
-- change the <session_id>
-- 
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

CREATE EVENT SESSION [trace_session_id] ON SERVER 
ADD EVENT sqlserver.query_post_execution_plan_profile(
    WHERE ([sqlserver].[session_id]=(<session_id>))),
ADD EVENT sqlserver.sp_statement_completed(
    WHERE ([sqlserver].[session_id]=(<session_id>))),
ADD EVENT sqlserver.sql_batch_completed(
    WHERE ([sqlserver].[session_id]=(<session_id>))),
ADD EVENT sqlserver.sql_statement_completed(
    WHERE ([sqlserver].[session_id]=(<session_id>)))
ADD TARGET package0.ring_buffer
WITH (STARTUP_STATE=OFF)
GO

-------------------------------------------------
--       Start and stop the Session            --
-------------------------------------------------
ALTER EVENT SESSION [trace_session_id] ON SERVER
STATE = START
GO

ALTER EVENT SESSION [trace_session_id] ON SERVER
STATE = STOP
GO

-------------------------------------------------
--               drop the session              --
-------------------------------------------------
DROP EVENT SESSION [trace_session_id] ON SERVER;