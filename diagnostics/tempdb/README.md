# TempDB

TempDB-related diagnostic queries for space usage and version store analysis.

## 📝 [active-transactions-using-version-store](./active-transactions-using-version-store.sql)

Displays active transactions maintaining version store with session information and transaction elapsed time.

## 📝 [current-temp-tables](./current-temp-tables.sql)

Lists current temporary tables in tempdb with creation date, modification date, and row counts.

## 📝 [temp-tables-structure](./temp-tables-structure.sql)

Shows the structure of temporary tables in tempdb including column names and data types.

## 📝 [tempdb-space-usage](./tempdb-space-usage.sql)

Provides summary of tempdb space allocation by object type including user and internal objects.

## 📝 [top-version-generators](./top-version-generators.sql)

Identifies tables generating the most row versions, sorted by version store usage in kilobytes.

## 📝 [version-store-by-transaction](./version-store-by-transaction.sql)

Details version store usage by transaction with session information and allocation/deallocation metrics.

## 📝 [version-store-content-by-index](./version-store-content-by-index.sql)

Shows version store records grouped by index with transaction sequence numbers and record lengths.

## 📝 [version-store-content-detail](./version-store-content-detail.sql)

Provides detailed row version records from version store including transaction and version sequence numbers.

## 📝 [version-store-usage](./version-store-usage.sql)

Shows tempdb space usage breakdown including user objects, internal objects, and version store space.
