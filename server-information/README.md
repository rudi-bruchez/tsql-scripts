# Server Information

Scripts for gathering SQL Server instance information: version, hardware, memory, and configuration.

## 📝 [check-cpu.ps1](./check-cpu.ps1)

PowerShell script to retrieve CPU information from Windows including processor details, number of cores, logical processors, and clock speed. Also detects if running on a virtual machine (Hyper-V, VMware, VirtualBox, KVM).

## 📝 [cores-and-numa](./cores-and-numa.sql)

Comprehensive CPU and NUMA topology analysis showing CPU count per NUMA node, scheduler configuration, edition, VM type, soft-NUMA settings, and memory allocation per node. Essential for understanding hardware topology.

## 📝 [deprecated-features](./deprecated-features.sql)

Lists deprecated SQL Server features that are being used based on performance counters. Helps identify code that should be modernized before upgrading SQL Server.

## 📝 [free-disk-space](./free-disk-space.sql)

Shows free disk space for all fixed drives using `sys.dm_os_enumerate_fixed_drives`. Available in SQL Server 2019 and later.

## 📝 [get-sqlserver-log-directory](./get-sqlserver-log-directory.sql)

Returns the path to the SQL Server error log directory. Useful for scripts that need to access log files.

## 📝 [os-memory](./os-memory.sql)

Quick view of available and total physical memory on the server from the OS perspective using `sys.dm_os_sys_memory`.

## 📝 [quick-audit](./quick-audit.sql)

Essential information to gather when first connecting to a SQL Server: Windows version, memory, NUMA nodes, CPU count, max server memory, cost threshold for parallelism, MAXDOP, page life expectancy, buffer cache hit ratio, and instant file initialization status.

## 📝 [remove-telemetry](./remove-telemetry.sql)

Stops and disables the SQL Server telemetry Extended Events session for privacy or performance reasons.

## 📝 [schedulers](./schedulers.sql)

Basic SQLOS scheduler information showing idle status, task counts, worker counts, and aggregated totals. Useful for CPU load analysis.

## 📝 [server-uptime](./server-uptime.sql)

Shows SQL Server start time and uptime in days and hours using `sys.dm_os_sys_info`.

## 📝 [sql-version](./sql-version.sql)

Retrieves detailed SQL Server version information including product version, edition, service pack level, cumulative update, KB article link, and CLR version.

## 📝 [sqlos_memory](./sqlos_memory.sql)

Shows SQL Server process memory usage including reserved and committed virtual address space from `sys.dm_os_process_memory`.

## Subdirectories

### 📁 [connections](./connections/)

Connection-related queries.

### 📁 [memory](./memory/)

Memory-specific diagnostics.
