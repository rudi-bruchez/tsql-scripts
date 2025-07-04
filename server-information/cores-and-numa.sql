-----------------------------------------------------------------
-- CPU et NUMA Nodes 
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
	parent_node_id as NumaNode, 
	COUNT(*) as CPU, 
	SUM(CAST(is_online as tinyint)) as NbOnline,
    SUM(COUNT(*)) OVER () as total_CPU,
	SUM(SUM(CAST(is_online as tinyint))) OVER () as TotalOnline
FROM sys.dm_os_schedulers
WHERE status LIKE N'VISIBLE%'
AND STATUS NOT LIKE '%(DAC)'
GROUP BY parent_node_id
ORDER BY parent_node_id
OPTION (RECOMPILE, MAXDOP 1);

SELECT 
    CAST(SERVERPROPERTY('Edition') AS NVARCHAR(128)) as edition,
    virtual_machine_type_desc as virtual_machine_type,
    softnuma_configuration_desc as softnuma_configuration,
    socket_count,
    cores_per_socket,
    numa_node_count,
    scheduler_count,
    hyperthread_ratio
FROM sys.dm_os_sys_info
OPTION (RECOMPILE, MAXDOP 1);

SELECT 
    parent_node_id,
    scheduler_id,
    cpu_id,
    status,
    is_online
FROM sys.dm_os_schedulers
WHERE status = 'VISIBLE ONLINE'
ORDER BY parent_node_id, scheduler_id
OPTION (RECOMPILE, MAXDOP 1);

-- Memeory per NUMA node
SELECT 
    memory_node_id AS NodeID,
    pages_kb / 1024 AS PagesMB,
    virtual_address_space_committed_kb / 1024 AS CommittedMB,
    foreign_committed_kb / 1024 AS ForeignMB
FROM sys.dm_os_memory_nodes
WHERE memory_node_id < 64
OPTION (RECOMPILE, MAXDOP 1);
