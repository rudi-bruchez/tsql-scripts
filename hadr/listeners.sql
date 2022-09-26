-----------------------------------------------------------------
-- get AG listeners information
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	g.name as AG, 
	agl.dns_name, 
	agl.is_conformant, 
	agl.port, 
	agl.ip_configuration_string_from_cluster,
	aglip.ip_address,
	aglip.ip_subnet_mask,
	aglip.is_dhcp,
	aglip.network_subnet_ip,
	aglip.network_subnet_ipv4_mask,
	aglip.network_subnet_prefix_length,
	aglip.state_desc
FROM sys.availability_group_listeners agl
JOIN sys.availability_group_listener_ip_addresses aglip ON agl.listener_id = aglip.listener_id
JOIN sys.availability_groups g ON agl.group_id = g.group_id
ORDER BY g.name, agl.dns_name
OPTION (RECOMPILE, MAXDOP 2);