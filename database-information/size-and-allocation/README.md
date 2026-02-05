# Size and Allocation

Scripts for analyzing database sizes, file allocation, and storage.

## 📝 [allocation-analysis](./allocation-analysis.sql)

Analyzes index allocation including partition information, pages, rows, compression, and data page statistics for a specific table.

## 📝 [check-allocation](./check-allocation.sql)

Uses DBCC IND and dm_db_database_page_allocations to examine page-level allocation details (IAM, GAM, SGAM pages).

## 📝 [database-files](./database-files.sql)

Lists all database files (data and log) with physical names, total size, available space, filegroups, growth settings, and file state.

## 📝 [database-files-details](./database-files-details.sql)

Extended file information including LSN values, file properties, max size, growth configuration, and filegroup details for advanced troubleshooting.

## 📝 [database-sizes](./database-sizes.sql)

Reports database and transaction log size using performance counters, including percent log used, recovery model, log reuse wait reason, and log backup history.

## 📝 [filegroup-analysis](./filegroup-analysis.sql)

Three-part query showing filegroup structure, objects/indexes allocated to filegroups, and total pages per filegroup.

## 📝 [number-of-files-per-database](./number-of-files-per-database.sql)

Summarizes file count per database by type (ROWS/LOG) with total size calculations across all databases.

## 📝 [objects-in-filegroups](./objects-in-filegroups.sql)

Maps objects and indexes to filegroups showing which physical files contain specific table/index data.

## 📝 [partition-information](./partition-information.sql)

Detailed partition analysis for partitioned objects showing partition boundaries, filegroup placement, compression, and size metrics.

## 📝 [partitioned-objects-by-partition-function](./partitioned-objects-by-partition-function.sql)

Lists all objects partitioned on a specific partition function with row counts, size, and compression details per partition.

## 📝 [table-sizes](./table-sizes.sql)

Reports table sizes showing row counts, compression type, data pages, and size in MB for storage capacity planning.

## 📝 [tables-allocation](./tables-allocation.sql)

Displays table allocation details including filegroup placement and file names for storage analysis.

## 📝 [used-space-in-current-db](./used-space-in-current-db.sql)

Calculates total used space in current database by querying master_files and FILEPROPERTY.
