# Statistics

Scripts for analyzing column and index statistics.

## 📝 [drop-duplicate-stats](./drop-duplicate-stats.sql)

Identifies and generates DDL to drop redundant auto-created statistics on columns that now have index statistics.

## 📝 [statistics](./statistics.sql)

Comprehensive statistics report showing column statistics with last update time, rows modified, modification counter, and DDL for update/drop operations.

## 📝 [statistics-for-pre2012](./statistics-for-pre2012.sql)

Legacy statistics analysis for SQL Server pre-2012 using sysindexes DMV, showing statistics age and modification rates to identify stale statistics.

## 📝 [string-summary](./string-summary.sql)

Decodes the string summary of a statistics object (the sampled trie behind `String Index = YES` in `DBCC SHOW_STATISTICS`), lists the sampled strings and estimates a `LIKE` pattern as the optimizer does. Needs the dedicated administrator connection; the format is undocumented.

## 📝 [user-created-statistics](./user-created-statistics.sql)

Lists user-created (manual) statistics with their columns, in the statistics key order, and the `DROP STATISTICS` DDL for each one.
