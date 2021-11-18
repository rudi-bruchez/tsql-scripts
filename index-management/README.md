# Index management queries

## &#x21E8; [index on table](./index-on-table.sql)

List indexes on a specific table, with simple usage statistics, like # of seeks and scans, fragmentation and index size.

## &#x21E8; [operational stats](./index-operational-stats.sql)

Retrieves *operational stats* on indexes. Operational stats are physical access statistics accumulated since last instance restart, to see hone many time the index was modified, how many page allocations occured at different levels of the index, etc.

You can choose a specific table name, or get the stats for all indexes in the database.

## &#x21E8; [physical stats](./index-physical-stats.sql)

Retrieves *physical stats* on indexes. Mainly used to check index fragmentation.

## &#x21E8; [index usage](./index-usage.sql)

Run this to see index usage information for all tables or a specific table.

Tips :
- uncomment the last column at the end of que query to generate REBUILD code to compress your indexes with ROW compression.
