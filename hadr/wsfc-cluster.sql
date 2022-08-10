-----------------------------------------------------------------
-- WSFC cluster information
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	c.cluster_name,
	c.quorum_type_desc as quorum_type,
	c.quorum_state_desc as quorum_state
FROM sys.dm_hadr_cluster c
OPTION (RECOMPILE, MAXDOP 1);