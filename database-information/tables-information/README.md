# Information on tables

## 📝 [Number of NULL in tables](./number-of-NULL-in-table.sql)

On a specific table, finds all nullable columns and counts the number of NULL present in each columns.

## 📝 [Search columns by name](./search-columns-by-name.sql)

Searches columns in tables, by their name and generate sql to inspect column content.

## 📝 [Tables and columns](./tables-and-columns.sql)

Simply lists tables and columns.

## 📝 [Tables with deprecated LOB types](./tables-with-deprecated-lob-types.sql)

`IMAGE`, `TEXT` and `NTEXT` data types are deprecated since SQL Server 2000. But you still find plenty of columns
with this type in your databases. This query lists the tables containing old LOB columns, and shows the pages allocations.

## 📝 [Tables with high columns number](./tables-with-high-columns-number.sql)

Lists tables with a high number of columns (those tables are probably badly modeled).

## 📝 [Tables with LOB](./tables-with-LOB.sql)

Lists tables containing `(N)VARCHAR(MAX)` or `VARBINAY(MAX)` columns, along with pages allocation.
