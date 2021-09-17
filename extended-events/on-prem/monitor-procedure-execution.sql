CREATE EVENT SESSION [procedure] ON SERVER 
ADD EVENT sqlserver.rpc_completed(
    ACTION(
		sqlserver.client_app_name,
		sqlserver.client_hostname,
		sqlserver.sql_text,
		sqlserver.username
	)
    WHERE ([object_name]=N'<PROCEDURE NAME>'))
	--WHERE ([object_name]<>N'sp_reset_connection'))
ADD TARGET package0.ring_buffer
WITH (
	MAX_MEMORY=4096 KB,
	EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
	MAX_DISPATCH_LATENCY=30 SECONDS,
	MAX_EVENT_SIZE=0 KB,
	MEMORY_PARTITION_MODE=NONE,
	TRACK_CAUSALITY=OFF,
	STARTUP_STATE=OFF
)
GO


