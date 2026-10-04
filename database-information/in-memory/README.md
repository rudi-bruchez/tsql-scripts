# In-Memory OLTP

Scripts for In-Memory OLTP (Hekaton) diagnostics and management.

## 📝 [in-memory-consumers](./in-memory-consumers.sql)

Reports In-Memory OLTP memory consumption by consumer type (table, index), showing allocated vs. used bytes and total database memory usage.

## 📝 [list-in-memory-tables](./list-in-memory-tables.sql)

Enumerates In-Memory OLTP tables and table types with durability settings, useful for workload management and memory configuration.

## 📝 [natively-compiled-procs](./natively-compiled-procs.sql)

Identifies natively compiled modules (stored procedures and, since SQL Server 2016, scalar functions and triggers), which are compiled to machine code for In-Memory OLTP.
