# Indexes

Index metadata, structure, and analysis scripts.

## 📝 [fill-factor](./fill-factor.sql)

Analyzes indexes with non-default fill factors, showing fragmentation, compression, pages in buffer, and free space analysis for tuning purposes.

## 📝 [fragmentation-analysis](./fragmentation-analysis.sql)

Index fragmentation analysis showing fragmentation percentage, page count, allocation type and forwarded records, with a schema-qualified `ALTER INDEX ... REBUILD` (or `ALTER TABLE ... REBUILD` for a heap) statement for every index of more than 20 pages, fragmented or not: pick the ones to run from the fragmentation column.

## 📝 [indexed-views](./indexed-views.sql)

Lists indexed views (views with clustered indexes) which are important for query optimization and maintenance planning.

## 📝 [indexes-on-a-table](./indexes-on-a-table.sql)

Lists all indexes on a specific table with column information, usage statistics, row counts, partitions, and whether indexes are disabled or hypothetical.

## 📝 [normalize-index-names](./normalize-index-names.sql)

Generates T-SQL to rename indexes to follow naming conventions (PK_, CIX_, NIX_) based on index type and columns.
