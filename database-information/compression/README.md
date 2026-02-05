# Compression

Data compression analysis, estimation, and implementation scripts.

## 📝 [compressed-objects](./compressed-objects.sql)

Lists all objects (tables/indexes) that currently have data compression enabled (ROW or PAGE) with details on index types and partitions.

## 📝 [estimate-compression-benefits-on-a-database](./estimate-compression-benefits-on-a-database.sql)

Comprehensive database-level compression analysis using cursors to estimate benefits for all tables/partitions with error handling.

## 📝 [estimate-compression-benefits-on-all-tables](./estimate-compression-benefits-on-all-tables.sql)

Batch analysis of compression benefits across all tables in database, showing current/compressed sizes, gain percentages, and total potential savings.

## 📝 [estimate-compression-benefits-on-a-table](./estimate-compression-benefits-on-a-table.sql)

Estimates compression savings for a specific table's indexes by comparing current vs. compressed sizes and calculating potential space reduction percentages.

## 📝 [uncompressed-objects](./uncompressed-objects.sql)

Identifies uncompressed objects and generates ALTER statements to apply ROW compression with configurable options for online operations and MAXDOP.
