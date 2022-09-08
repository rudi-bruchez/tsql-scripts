-----------------------------------------------------------------
-- logon trigger to create a DAF : Database Application Firewall
-- in case there is no other solutions and the sysadmin is not
-- helping
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

USE [master]
GO

IF OBJECT_ID('BadLogonLog') IS NULL
BEGIN
	CREATE TABLE [dbo].[BadLogonLog](
		[quand] [datetime2](2) NOT NULL DEFAULT (SYSDATETIME()),
		[hostname] [sysname] NOT NULL DEFAULT (HOST_NAME()),
		[IP] [varchar](48) NULL
	)
END
GO

CREATE OR ALTER TRIGGER [LogonBLOCKTrigger]
ON ALL SERVER
FOR LOGON
AS
BEGIN
    IF 
		HOST_NAME() IN (N'DESKTOP1', N'DESKTOP2')
		OR EXISTS (SELECT 1 FROM sys.dm_exec_connections WHERE session_id = @@SPID 
                   AND client_net_address IN ('10.1.1.8', '10.1.1.9'))
    BEGIN
		PRINT '';
	END ELSE BEGIN 
        ROLLBACK;
		INSERT INTO Master.dbo.BadLogonLog (IP)
		SELECT client_net_address FROM sys.dm_exec_connections WHERE session_id = @@SPID;
    END
END
GO

ENABLE TRIGGER [LogonBLOCKTrigger] ON ALL SERVER
-- DISABLE TRIGGER [LogonBLOCKTrigger] ON ALL SERVER
GO


