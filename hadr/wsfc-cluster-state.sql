-----------------------------------------------------------------
-- state of the WSFC cluster
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	cm.member_name,
	cm.member_type_desc as member_type,
	cm.member_state_desc as member_state,
	cm.number_of_quorum_votes
FROM sys.dm_hadr_cluster_members cm
OPTION (RECOMPILE, MAXDOP 1);