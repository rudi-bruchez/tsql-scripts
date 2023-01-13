-----------------------------------------------------------------
-- Remove useless schemas that are created by default in SQL Server
-- for historical reasons.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

USE [<you database>]
GO
DROP SCHEMA [db_accessadmin];
DROP SCHEMA [db_backupoperator];
DROP SCHEMA [db_datareader];
DROP SCHEMA [db_datawriter];
DROP SCHEMA [db_ddladmin];
DROP SCHEMA [db_denydatareader];
DROP SCHEMA [db_denydatawriter];
DROP SCHEMA [db_owner];
DROP SCHEMA [db_securityadmin];
GO
