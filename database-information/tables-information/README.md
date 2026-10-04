# Information on tables

## 📝 [Primary keys](./primary-keys.sql)

Lists the primary keys of all tables in the current database, with their columns in key order. Uses `STRING_AGG`, so SQL Server 2017 or later.

## 📝 [Foreign keys](./foreign-keys.sql)

Lists the foreign key constraints of the current database with their columns, from `INFORMATION_SCHEMA`. Only the referencing side is shown, not the referenced table.

## 📝 [Table usage](./table-usage.sql)

Shows, for each user table (heap or clustered index), the number of leaf inserts, updates, deletes and range scans from `sys.dm_db_index_operational_stats`, ordered by range scans. Counters are kept while the table metadata stays in cache, so mostly since the last restart.

## 📝 [Number of NULL in tables](./number-of-NULL-in-table.sql)

On a specific table, finds all nullable columns and counts the number of NULL present in each columns.

## 📝 [Search columns by data type](./search-by-column-types.sql)

Lists all columns of the current database (tables and views) of a given set of data types, with their default and nullability. The list is hard coded to date and time types: edit the `DATA_TYPE IN (...)` filter for other types.

## 📝 [Search columns by name](./search-columns-by-name.sql)

Searches columns in tables, by their name and generate sql to inspect column content.

## 📝 [Tables and columns](./tables-and-columns.sql)

Lists the columns of every table with their definition (type, length, nullability, default) and the table row count, largest tables first. A commented `WHERE DATA_TYPE IN (...)` filter restricts the list to some data types.

## 📝 [Tables with deprecated LOB types](./tables-with-deprecated-lob-types.sql)

`IMAGE`, `TEXT` and `NTEXT` data types are deprecated since SQL Server 2000. But you still find plenty of columns
with this type in your databases. This query lists the tables containing old LOB columns, and shows the pages allocations.

## 📝 [Varchar size analysis](./varchar-size-analysis.sql)

For one table, compares the declared length of each `VARCHAR` column with the longest value actually stored (`MAX(LEN())`). Set `@schema` and `@table` first. It scans the table once per column, so it is slow on large tables. `NVARCHAR` columns are ignored.

## 📝 [Tables with high columns number](./tables-with-high-columns-number.sql)

Lists tables with a high number of columns (those tables are probably badly modeled).

## 📝 [Tables with LOB](./tables-with-LOB.sql)

Lists tables containing `(N)VARCHAR(MAX)` or `VARBINAY(MAX)` columns, along with pages allocation.

## 📝 [LOB usage](./LOB-usage.sql)

For one table, analyzes the pages of the heap or clustered index currently in the buffer pool (`sys.dm_os_buffer_descriptors`), by page type: pages in memory, rows per page and free space. Replace `<TABLE NAME` in `OBJECT_ID()` first. Only cached pages are counted, and the `LOB_DATA` filter is commented out, so all page types are shown by default.

## 📝 [Forwarded records](./forwarded-records.sql)

Lists the heaps of the current database that contain forwarded records, with page count, page density and row count. It runs `sys.dm_db_index_physical_stats` in `DETAILED` mode on every heap, which reads all their pages: expect a long run on a large database.

## 📝 [Indexes with wide rows](./tables-with-wide-row.sql)

Lists indexes whose columns can add up to more than 8,060 bytes, the in-row size limit, based on declared column lengths (`MAX` and `XML` columns count as 0, `TEXT` and `IMAGE` as 16 bytes). Despite the file name, it sums the columns of each index (`sys.index_columns`), not all the columns of the table, so heaps do not appear.
