-----------------------------------------------------------------
-- Configure blob storage for backup from on-prem SQL Server
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Check if the credential exists
SELECT *
FROM sys.credentials

-- Create a credential for the storage account.
-- The credential name must be the blob storage URL
-- It must be a shared access signature (SAS) token
-- If it already exists, its secret is replaced
IF EXISTS (SELECT * FROM sys.credentials WHERE name = N'https://pachasql.blob.core.windows.net/backups')
	ALTER CREDENTIAL [https://pachasql.blob.core.windows.net/backups]
	WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
	SECRET = '<SAS Token>';
ELSE
	CREATE CREDENTIAL [https://pachasql.blob.core.windows.net/backups]
	WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
	SECRET = '<SAS Token>';

-- Backup to the URL
BACKUP DATABASE [AdventureWorks2017]
TO URL = 'https://pachasql.blob.core.windows.net/backups/AdventureWorks2017.bak'
WITH CHECKSUM, STATS = 10, COMPRESSION, FORMAT, INIT;