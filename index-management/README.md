# Index management queries

## 📝 [clustered index on uniqueidentifier](./clustered-index-on-uniqueidentifier.sql)

Lists tables that have a clustered index on a `UNIQUEIDENTIFIER` column. If so, this is bad. Look for table fragmentation, `INSERT`'s bad performances, etc. Check at least that the default value is set to `NEWSEQUENTIALID()`.

## 📝 [index on table](./index-on-table.sql)

Lists indexes on a specific table, with simple usage statistics, like # of seeks and scans, fragmentation and index size.

## 📝 [operational stats](./index-operational-stats.sql)

Retrieves *operational stats* on indexes. Operational stats are physical access statistics accumulated since last instance restart, to see hone many time the index was modified, how many page allocations occured at different levels of the index, etc.

You can choose a specific table name, or get the stats for all indexes in the database.

## 📝 [physical stats](./index-physical-stats.sql)

Retrieves *physical stats* on indexes. Mainly used to check index fragmentation.

## 📝 [index usage](./index-usage.sql)

Run this to see index usage information for all tables or a specific table.

Tips :
- uncomment the last column at the end of then query to generate REBUILD code to compress your indexes with ROW compression.

## 📝 [missing indexes](./missing-indexes.sql)

Lists missing indexes spotted by the optimizer, in the current database.
