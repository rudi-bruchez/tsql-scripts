# Index management queries

## 📝 [clustered index on uniqueidentifier](./clustered-index-on-uniqueidentifier.sql)

Lists tables that have a clustered index on a `UNIQUEIDENTIFIER` column. If so, this is bad. Look for table fragmentation, `INSERT`'s bad performances, etc. Check at least that the default value is set to `NEWSEQUENTIALID()`.

## 📝 [nonclustered primary keys](./nonclustered-indexes-on-primary_key.sql)

Lists primary keys implemented as nonclustered indexes in the current database, with their size in MB. Useful to spot tables that are heaps or whose clustered index is on another key.

## 📝 [index on table](./index-on-table.sql)

Lists indexes on a specific table, with simple usage statistics, like # of seeks and scans, fragmentation and index size.

## 📝 [operational stats](./index-operational-stats.sql)

Retrieves *operational stats* on indexes. Operational stats are physical access statistics accumulated since last instance restart, to see hone many time the index was modified, how many page allocations occured at different levels of the index, etc.

You can choose a specific table name, or get the stats for all indexes in the database.

## 📝 [physical stats, limited](./index-physical-stats-limited.sql)

Retrieves *physical stats* on indexes with `sys.dm_db_index_physical_stats` in `LIMITED` mode: page count, fragmentation, fragment count, index depth, per allocation unit. `LIMITED` only reads the pages above the leaf level, so it is cheap and the right choice to check fragmentation. Set `@table_name` to restrict to one table (`'%'` for all).

## 📝 [physical stats, detailed](./index-physical-stats-detailed.sql)

Same query in `DETAILED` mode, per partition and for the leaf level only, adding page density (`avg_page_space_used_in_percent`), row count, ghost and version ghost records, and forwarded records. `DETAILED` reads every page of every index: on a large database, run it on one table with `@table_name`, and preferably outside business hours.

## 📝 [index usage](./index-usage.sql)

Run this to see index usage information for all tables or a specific table.

Tips :
- uncomment the last column at the end of then query to generate REBUILD code to compress your indexes with ROW compression.

## 📝 [unused indexes](./unused-indexes.sql)

Lists nonclustered, non-unique, non primary key indexes that have been updated but never sought nor scanned since the last instance restart (`sys.dm_db_index_usage_stats`), with their key, size and the modification rate per minute. The last column generates the `DROP INDEX` statement. Check `Period_days` first: a short uptime makes the result meaningless.

## 📝 [missing indexes](./missing-indexes.sql)

Lists missing indexes spotted by the optimizer, in the current database.

## 📝 [index scans](./index-scans.sql)

Searches the plan cache (`sys.dm_exec_query_stats`) for plans containing an `IndexScan` operator on the current database, and returns the table, the index, the statement text, logical reads and execution count. Uncomment the last line to filter on one table. Parsing cached plans as XML can be heavy on a large plan cache.

## 📝 [index used by queries](./index-used-by-queries.sql)

Finds the cached query plans that mention a given index, by a text search of the plan XML in the plan cache. Set `@indexName` to the index name before running. Returns the query text, the plan, execution count, and seeks and scans of the index.

## 📝 [index used by queries, Query Store](./index-used-by-queries-query-store.sql)

Same search in the plans stored by the Query Store of the current database (`sys.query_store_plan`), which keeps plans that left the cache. Set `@indexName` before running. Requires Query Store enabled on the database.

## 📝 [index used by procedures](./index-used-by-proc.sql)

Lists the cached stored procedures (`sys.dm_exec_procedure_stats`) whose plan references one of the given indexes. Edit the `IN (N'[IX1]', N'[IX2]')` list in the `WHERE` clause with your index names, brackets included.
