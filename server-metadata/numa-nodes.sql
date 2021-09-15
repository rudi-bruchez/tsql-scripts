SELECT 
	parent_node_id as NumaNode, 
	COUNT(*) as CPU, 
	SUM(CAST(is_online as tinyint)) as NbOnline
FROM sys.dm_os_schedulers
WHERE status LIKE N'VISIBLE%'
AND STATUS NOT LIKE '%(DAC)'
GROUP BY parent_node_id
ORDER BY parent_node_id;
