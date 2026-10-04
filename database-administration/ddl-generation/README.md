# DDL Generation

Scripts that generate DDL statements for database schema changes.

## 📝 [change-collation](./change-collation.sql)

Generates ALTER TABLE statements to change column collation to a specified collation for all columns of base tables not matching it in the current database, keeping their length and nullability. Computed columns are skipped; a column used by an index, a constraint or a computed column must be freed first.

## 📝 [change-database-owner](./change-database-owner.sql)

Generates DDL commands to change database owner to sa for databases where owner is not sa, with rollback commands included.

## 📝 [correct-fillfactor](./correct-fillfactor.sql)

Identifies indexes with non-standard fill factors (1-99) and generates ALTER INDEX commands to set them to 100 with online and sort in tempdb options.

## 📝 [disable-indexes](./disable-indexes.sql)

Generates DISABLE and REBUILD commands for nonclustered indexes on specified tables to support bulk import operations.

## 📝 [drop-database-users](./drop-database-users.sql)

Prints a DROP USER command for every user of the current database. Runs in listing mode by default; set `@execute = 1` to run the commands, with error handling for users that own objects.

## 📝 [move-tempdb-files](./move-tempdb-files.sql)

Generates ALTER DATABASE statements to move tempdb data and log files to a specified folder, extracting filenames from current paths.

## 📝 [remove-files](./remove-files.sql)

Generates DDL to consolidate database files by increasing max file size on primary files and removing secondary files using DBCC SHRINKFILE and ALTER DATABASE.

## 📝 [revoke-proc-privileges](./revoke-proc-privileges.sql)

Generates REVOKE EXECUTE commands on all stored procedures for every database user and role to remove execution privileges.

## 📝 [text-to-varchar-max](./text-to-varchar-max.sql)

Generates ALTER TABLE statements to migrate deprecated TEXT columns to VARCHAR(MAX) with proper NULL/NOT NULL preservation and table rebuild commands.
