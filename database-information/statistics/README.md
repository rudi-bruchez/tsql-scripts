# Statistics

Scripts for analyzing column and index statistics.

## 📝 [drop-duplicate-stats](./drop-duplicate-stats.sql)

Identifies and generates DDL to drop redundant auto-created statistics on columns that now have index statistics.

## 📝 [statistics](./statistics.sql)

Comprehensive statistics report showing column statistics with last update time, rows modified, modification counter, and DDL for update/drop operations.

## 📝 [statistics-for-pre2012](./statistics-for-pre2012.sql)

Legacy statistics analysis for SQL Server pre-2012 using sysindexes DMV, showing statistics age and modification rates to identify stale statistics.

## 📝 [user-created-statistics](./user-created-statistics.sql)

Lists user-created (manual) statistics with columns, last update time, and DDL for dropping unused statistics.
