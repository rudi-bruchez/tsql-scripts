-----------------------------------------------------------------
-- WSFC cluster networks information
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT *
FROM sys.dm_hadr_cluster_networks
ORDER BY member_name, network_subnet_ip
OPTION (RECOMPILE, MAXDOP 1);