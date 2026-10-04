# Stored Procedure Execution Stats

Scripts for analyzing stored procedure execution performance.

## 📝 [monitor-proc-execution](./monitor-proc-execution.sql)

Monitors execution statistics for specific stored procedures including elapsed time, execution count, and resource usage.

## 📝 [procedure-execution-analysis](./procedure-execution-analysis.sql)

Returns execution information for all stored procedures in the current database sorted by execution frequency.

## 📝 [procedure-execution-analysis-detailed](./procedure-execution-analysis-detailed.sql)

Provides detailed statement-level analysis for a single stored procedure including plan generation numbers and execution plans.

## 📝 [procedures-by-execution-count](./procedures-by-execution-count.sql)

Lists the most executed stored procedures in the current database with execution counts and performance metrics.

## 📝 [tracking-recompiles](./tracking-recompiles.sql)

Lists the modules of the current database whose code contains SET ARITHABORT, a construct likely to trigger recompilations, with their execution statistics when they are in the plan cache.
