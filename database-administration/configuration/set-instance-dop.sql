-----------------------------------------------------------------
-- Set instance degree of parallelism (DOP) based on the logical
-- CPUs of a NUMA node, and cost threshold for parallelism.
--
-- Runs in listing mode by default: it prints what it would change.
-- Set @execute = 1 to apply.
--
-- Only settings still at their default value are changed
-- (MAXDOP 0, cost threshold 5): a value somebody chose is left alone
-- and reported.
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;

DECLARE @execute bit = 0;
DECLARE @cost_threshold int = 80;

-- Logical CPUs of the smallest NUMA node the instance schedules on.
-- cpu_count / hyperthread_ratio is the number of sockets, not of cores,
-- and gave 1 on a 22-CPU machine.
DECLARE @cpu_per_node int = (
	SELECT MIN(n.cpus)
	FROM (
		SELECT parent_node_id, COUNT(*) AS cpus
		FROM sys.dm_os_schedulers
		WHERE status = N'VISIBLE ONLINE'
		GROUP BY parent_node_id
	) AS n
);

-- 8 logical CPUs or more per node: 4, otherwise half of them, at least 1.
DECLARE @dop int = CASE
	WHEN @cpu_per_node >= 8 THEN 4
	WHEN @cpu_per_node >= 2 THEN @cpu_per_node / 2
	ELSE 1
END;

DECLARE @current_ctfp int = (SELECT CAST(value AS int) FROM sys.configurations WHERE configuration_id = 1538);
DECLARE @current_dop  int = (SELECT CAST(value AS int) FROM sys.configurations WHERE configuration_id = 1539);

PRINT CONCAT('Logical CPUs per NUMA node: ', @cpu_per_node);

IF @current_ctfp = 5
	PRINT CONCAT('cost threshold for parallelism: 5 -> ', @cost_threshold);
ELSE
	PRINT CONCAT('cost threshold for parallelism: left at ', @current_ctfp, ' (not the default)');

IF @current_dop = 0
	PRINT CONCAT('max degree of parallelism: 0 -> ', @dop);
ELSE
	PRINT CONCAT('max degree of parallelism: left at ', @current_dop, ' (not the default)');

IF @execute = 1
BEGIN
	EXEC sys.sp_configure N'show advanced options', 1;
	RECONFIGURE;

	IF @current_ctfp = 5
		EXEC sys.sp_configure N'cost threshold for parallelism', @cost_threshold;

	IF @current_dop = 0
		EXEC sys.sp_configure N'max degree of parallelism', @dop;

	RECONFIGURE;

	EXEC sys.sp_configure N'show advanced options', 0;
	RECONFIGURE;
END
ELSE
	PRINT 'Listing mode: nothing changed. Set @execute = 1 to apply.';

SELECT name, value, value_in_use
FROM sys.configurations
WHERE configuration_id IN (1538, 1539);
