# Size and Allocation

Scripts for analyzing database sizes, file allocation, and storage.

## 📝 [allocation-analysis](./allocation-analysis.sql)

Analyzes index allocation including partition information, pages, rows, compression, and data page statistics for a specific table.

## 📝 [check-allocation](./check-allocation.sql)

Demo script tied to a sample database (PachaDataFormation): uses DBCC IND, DBCC PAGE and sys.dm_db_database_page_allocations to examine the pages allocated to a table and its IAM page. Object names and page numbers are hardcoded.

## 📝 [database-files](./database-files.sql)

Lists the files (data and log) of the current database with physical names, total size, available space, filegroups and file state.

## 📝 [database-files-details](./database-files-details.sql)

Extended file information including LSN values, file properties, max size, growth configuration, and filegroup details for advanced troubleshooting.

## 📝 [database-sizes](./database-sizes.sql)

Reports data and transaction log size of every user database using performance counters, including percent log used, recovery model and log reuse wait reason, with a total row. Set `@systemdbs = 1` to include msdb and tempdb.

## 📝 [filegroup-analysis](./filegroup-analysis.sql)

Three-part query showing filegroup structure, objects/indexes allocated to filegroups, and total pages per filegroup.

## 📝 [number-of-files-per-database](./number-of-files-per-database.sql)

Summarizes file count and total size per database and file type (ROWS/LOG) for all databases of the instance.

## 📝 [objects-in-filegroups](./objects-in-filegroups.sql)

Maps objects and indexes to filegroups showing which physical files contain specific table/index data. An index on a partition scheme is listed once per filegroup of the scheme. Same query as tables-allocation.

## 📝 [partition-information](./partition-information.sql)

Detailed partition analysis for partitioned objects showing partition boundaries, filegroup placement, compression, and size metrics.

## 📝 [partitioned-objects-by-partition-function](./partitioned-objects-by-partition-function.sql)

Lists all objects partitioned on a specific partition function with row counts, size, and compression details per index (all partitions summed).

## 📝 [table-sizes](./table-sizes.sql)

Reports table sizes per allocation unit type (IN_ROW_DATA, LOB_DATA, ROW_OVERFLOW_DATA), showing row counts, compression type, used pages, and size in MB for storage capacity planning.

## 📝 [tables-allocation](./tables-allocation.sql)

Displays table allocation details including filegroup placement and file names for storage analysis. An index on a partition scheme is listed once per filegroup of the scheme. Same query as objects-in-filegroups.

## 📝 [used-space-in-current-db](./used-space-in-current-db.sql)

Calculates total used space in current database by querying master_files and FILEPROPERTY.
