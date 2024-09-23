---------------------------------------------------------------------
-- Create AlwaysOn XEvent, because the default system AwlaysOn XEvent
-- is disabled by default in AWS RDS SQL Server
--
-- rudi@babaluga.com, go ahead license
---------------------------------------------------------------------

SET NOCOUNT ON;


/*
We cannot named it rds_*
Msg 50000, Level 16, State 1, Procedure rds_extended_events_trigger, Line 172
Unable to create/alter extended events session: Extended events session names 
starting with "RDS_" are reserved for RDS, please use a different name

*/
CREATE EVENT SESSION [urds_AlwaysOn_health] ON SERVER 
    ADD EVENT sqlserver.alwayson_ddl_executed,
    ADD EVENT sqlserver.availability_group_lease_expired,
    ADD EVENT sqlserver.availability_replica_automatic_failover_validation,
    ADD EVENT sqlserver.availability_replica_manager_state_change,
    ADD EVENT sqlserver.availability_replica_state,
    ADD EVENT sqlserver.availability_replica_state_change,
    ADD EVENT sqlserver.error_reported(
        WHERE ([error_number]=(9691) OR [error_number]=(35204) OR [error_number]=(9693) OR [error_number]=(26024) OR [error_number]=(28047) OR [error_number]=(26023) OR [error_number]=(9692) OR [error_number]=(28034) OR [error_number]=(28036) OR [error_number]=(28048) OR [error_number]=(28080) OR [error_number]=(28091) OR [error_number]=(26022) OR [error_number]=(9642) OR [error_number]=(35201) OR [error_number]=(35202) OR [error_number]=(35206) OR [error_number]=(35207) OR [error_number]=(26069) OR [error_number]=(26070) OR [error_number]>(41047) AND [error_number]<(41056) OR [error_number]=(41142) OR [error_number]=(41144) OR [error_number]=(1480) OR [error_number]=(823) OR [error_number]=(824) OR [error_number]=(829) OR [error_number]=(35264) OR [error_number]=(35265) OR [error_number]=(41188) OR [error_number]=(41189) OR [error_number]=(35217))),
    ADD EVENT sqlserver.hadr_db_partner_set_sync_state,
    ADD EVENT sqlserver.hadr_trace_message,
    ADD EVENT sqlserver.lock_redo_blocked,
    ADD EVENT sqlserver.sp_server_diagnostics_component_result(SET collect_data=(1)
        WHERE ([state]=(3))),
    ADD EVENT ucs.ucs_connection_setup
    ADD TARGET package0.event_file(SET filename=N'D:\rdsdbdata\Log\urds_AlwaysOn_health.xel',max_file_size=(100),max_rollover_files=(5))
    WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,
    TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO

ALTER EVENT SESSION urds_AlwaysOn_health ON SERVER
STATE = START;
