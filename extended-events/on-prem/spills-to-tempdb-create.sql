-----------------------------------------------------------------
-- tracing spills to tempdb in hashs and sorts
--
-- rudi@babaluga.com, go ahead license
--
-- uncomment event_file target if you need to persist the trace
-- results.
-----------------------------------------------------------------

CREATE EVENT SESSION [spills_to_tempdb] ON SERVER 
ADD EVENT sqlserver.exchange_spill(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.sql_text)
	),
ADD EVENT sqlserver.hash_spill_details(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.sql_text)
	),
ADD EVENT sqlserver.hash_warning(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.sql_text)
	),
ADD EVENT sqlserver.sort_warning(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name,sqlserver.sql_text)
    )
--ADD TARGET package0.event_file(SET filename=N'spills_to_tempdb',max_file_size=(50)),
ADD TARGET package0.ring_buffer
WITH (STARTUP_STATE=OFF)
GO

-- start the session
ALTER EVENT SESSION [spills_to_tempdb] ON SERVER STATE=START;
-- stop the session
/*
ALTER EVENT SESSION [spills_to_tempdb] ON SERVER STATE=STOP;
*/
