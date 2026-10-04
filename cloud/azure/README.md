# ☯ tsql-scripts for Azure SQL Database and Azure Managed Instances

Transact-SQL scripts for Azure SQL Database, and for using Azure from an on-premises SQL Server.

## 📝 [backup-to-blob-storage](./backup-to-blob-storage.sql)

Backs up an on-premises database to an Azure Blob Storage container: lists `sys.credentials`, sets a shared access signature credential named after the container URL, then runs `BACKUP DATABASE ... TO URL` with `CHECKSUM`, `COMPRESSION` and `FORMAT, INIT`. Replace the storage account and container URL, the `<SAS Token>` placeholder and the database name (`AdventureWorks2017`) before running. The script uses `ALTER CREDENTIAL`, which fails if the credential does not exist yet: use `CREATE CREDENTIAL` the first time.

## Subdirectories

### 📁 [azure-sql-database](./azure-sql-database/)

Scripts for Azure SQL Database (wait statistics, resource usage, IO, service level).
