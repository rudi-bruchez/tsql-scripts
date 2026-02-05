# Memory

Memory-related diagnostic queries: buffer pool, plan cache, and memory grants.

## 📝 [memory-analysis](./memory-analysis.sql)

Displays key memory metrics including max server memory, buffer pool size, page life expectancy, and memory grants pending.

## 📝 [memory-grants](./memory-grants.sql)

Shows live memory grants for executing queries with session context and query execution plans.

## 📝 [objects-in-buffer](./objects-in-buffer.sql)

Lists objects in the buffer pool for the current database with page counts and memory usage by table/index.

## 📝 [optimize-for-adhoc-workloads](./optimize-for-adhoc-workloads.sql)

Analyzes plan cache to show single-use plans vs. multi-use plans for evaluating the optimize for adhoc workloads setting.

## 📝 [pages-in-buffer](./pages-in-buffer.sql)

Lists pages in the buffer pool grouped by page type with counts for each type.

## 📝 [performance-counters](./performance-counters.sql)

Queries important memory and buffer performance counters including buffer cache hit ratio and page life expectancy.

## 📝 [plan-cache-analysis](./plan-cache-analysis.sql)

Provides detailed analysis of cached execution plans including cache attributes, creation time, and usage metrics.

## 📝 [plan-cache-usage](./plan-cache-usage.sql)

Summarizes plan cache usage by object type showing count and size for single-use vs. multi-use plans.

## 📝 [resource-semaphore](./resource-semaphore.sql)

Shows active memory grants for queries with session information and SQL text details.
