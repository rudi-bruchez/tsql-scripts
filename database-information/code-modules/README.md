# Code Modules

Scripts for analyzing stored procedures, functions, triggers, and other programmable objects.

## 📝 [inlineable-udf](./inlineable-udf.sql)

Lists scalar user-defined functions with their inline capability status, identifying functions that can benefit from inlining for better performance (SQL Server 2019+).

## 📝 [modules-using-temporary-tables](./modules-using-temporary-tables.sql)

Finds all code modules (procedures, functions) that create or reference temporary tables to identify modules with complex logic and potential performance issues.

## 📝 [search-in-modules](./search-in-modules.sql)

Template script to search for specific text patterns within stored procedures, functions, and triggers to locate code references.

## 📝 [triggers-in-database](./triggers-in-database.sql)

Report of the T-SQL DML triggers on tables and views of the current database, including type (INSTEAD OF/AFTER), target object, execution context, schema binding, state (enabled/disabled), and execution statistics from `sys.dm_exec_trigger_stats`. Database-level DDL triggers and CLR triggers are not listed.
