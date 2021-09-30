# Index management queries

## &#x21E8; [index on table](./index-on-table.sql)

Liste indexes on a specific table, with simple statistics.

## &#x21E8; [operational stats](./index-operational-stats.sql)

Retreives *operational stats* on indexes. Operational stats are physical access statistics accumulated since last instance restart, to see hone many time the index was modified, how many page allocations occured at different levels of the index, etc.

## &#x21E8; [index usage](./index-usage.sql)

Run this to see index usage information for all tables or a specific table.

Tips :
- uncomment the last column at the end of que query to generate REBUILD code to compress your indexes with ROW compression.
