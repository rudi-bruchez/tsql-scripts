# Compression

Data compression analysis, estimation, and implementation scripts.

## 📝 [compressed-objects](./compressed-objects.sql)

Lists all objects (tables/indexes) whose partitions have a compression setting other than NONE (ROW, PAGE, COLUMNSTORE or COLUMNSTORE_ARCHIVE) with details on index types and partitions.

## 📝 [estimate-compression-benefits-on-a-database](./estimate-compression-benefits-on-a-database.sql)

Comprehensive database-level compression analysis using cursors to estimate benefits for all tables/partitions with error handling.

## 📝 [estimate-compression-benefits-on-all-tables](./estimate-compression-benefits-on-all-tables.sql)

Batch analysis of compression benefits across all tables in database, showing current/compressed sizes, gain percentages, and total potential savings.

## 📝 [estimate-compression-benefits-on-a-table](./estimate-compression-benefits-on-a-table.sql)

Estimates compression savings for a specific table's indexes by comparing current vs. compressed sizes and calculating potential space reduction percentages.

## 📝 [uncompressed-objects](./uncompressed-objects.sql)

Identifies rowstore indexes and heaps whose partitions are not compressed (or only ROW compressed when the target is PAGE) and generates the ALTER ... REBUILD statements to compress them, with `PARTITION = n` on partitioned objects. Columnstore indexes, memory-optimized tables and tables with sparse columns are skipped. Configurable compression type (ROW by default), table name filter, ONLINE, RESUMABLE, MAXDOP and an optional `BACKUP LOG` to NUL between commands. The statements are only generated, not executed.
