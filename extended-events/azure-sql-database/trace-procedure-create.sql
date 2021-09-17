CREATE EVENT SESSION [trace-procedure] ON DATABASE 
ADD EVENT sqlserver.query_post_execution_plan_profile(
    WHERE ([sqlserver].[equal_i_sql_unicode_string]([object_name],N'<PROCEDURE NAME>'))),
ADD EVENT sqlserver.sp_statement_completed(
    WHERE ([object_id]=(<[PROCEDURE OBJECT ID]>)))
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO


