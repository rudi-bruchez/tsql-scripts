-----------------------------------------------------------------
-- PREEMPTIVE_OS_QUERYREGISTRY waits
-- Bug in SQL Server 2022. SQL queries might lookup Windows 
-- Registry values even for a simple query.
-- https://learn.microsoft.com/en-us/troubleshoot/sql/releases/sqlserver-2022/cumulativeupdate5#2351584
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


CREATE EVENT SESSION [Preemptive_QueryRegistry] ON SERVER 
ADD EVENT sqlos.wait_info_external(
    ACTION(
		package0.callstack_rva, 
		sqlserver.sql_text
	)
    WHERE (
		[package0].[equal_uint64]([wait_type],'PREEMPTIVE_OS_QUERYREGISTRY') 
		AND [opcode]='End')
	)
GO


