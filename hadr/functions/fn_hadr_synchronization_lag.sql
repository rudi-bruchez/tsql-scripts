-----------------------------------------------------------------
-- fn_hadr_synchronization_lag
-- Returns the synchronization lag in seconds between the primary 
-- and secondary replicas of an availability group
--
-- code adapted from https://dba.stackexchange.com/questions/60624/check-the-data-latency-between-two-always-on-availability-group-servers-in-async
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE master;
-- USE _dba;
GO

CREATE OR ALTER FUNCTION dbo.fn_hadr_synchronization_lag(
	@database_name sysname
)
RETURNS INT
AS BEGIN
	DECLARE @value INT;

	;WITH AG_Stats AS (
        SELECT  AR.replica_server_name,
                AG.name as AGName,
                HARS.role_desc, 
                DB_NAME(DRS.database_id) [DBName], 
                DRS.last_commit_time
        FROM sys.dm_hadr_database_replica_states DRS 
        JOIN sys.availability_replicas AR ON DRS.replica_id = AR.replica_id 
        JOIN sys.dm_hadr_availability_replica_states HARS ON AR.group_id = HARS.group_id 
            AND AR.replica_id = HARS.replica_id 
        JOIN [sys].[availability_groups] AG on AG.group_id = AR.group_id
    ),
    Pri_CommitTime AS (
        SELECT  replica_server_name
                , AGNAME
                , DBName
                , last_commit_time
        FROM    AG_Stats
        WHERE   role_desc = 'PRIMARY'),
    Sec_CommitTime AS (
        SELECT  replica_server_name
                , AGNAME
                , DBName
                , last_commit_time
        FROM    AG_Stats
        WHERE   role_desc = 'SECONDARY'
        )
    SELECT 
		@value = MAX(CASE 
                WHEN s.last_commit_time >= p.last_commit_time THEN DATEDIFF(ss,s.last_commit_time,p.last_commit_time) 
                ELSE DATEDIFF(ss,p.last_commit_time, CURRENT_TIMESTAMP) 
          END) --AS [Sync_Latency_Secs]
    FROM Pri_CommitTime p
    LEFT JOIN Sec_CommitTime s ON [s].[DBName] = [p].[DBName] and  s.AGNAME = p.AGNAME
	WHERE p.[DBName] = @database_name;

	RETURN @value;
END;