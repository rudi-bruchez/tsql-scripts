-----------------------------------------------------------------
-- Standard calls to Ola Hallengren procedures
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-------------------------------------------------
--           Full backups
-------------------------------------------------

EXECUTE _dba.dbo.DatabaseBackup 
	@Databases = 'USER_DATABASES',
	@Directory = '\\share\SQL\Backups',
	@BackupType = 'FULL',
	@Compress = 'Y',
	@Encrypt = 'Y',
	@EncryptionAlgorithm = 'AES_256',
	@ServerCertificate = 'sauvegardes',
	@CleanupTime = 48,
	@DirectoryStructure = '{DatabaseName}{DirectorySeparator}{BackupType}',
	@FileName = '{DatabaseName}_{BackupType}_{Year}{Month}{Day}_{Hour}{Minute}{Second}_{FileNumber}.{FileExtension}',
	@LogToTable = 'Y';

-------------------------------------------------
--          Transaction log backups
-------------------------------------------------

EXECUTE _dba.dbo.DatabaseBackup 
	@Databases = 'USER_DATABASES',
	@Directory = '\share\SQL\Backups',
	@BackupType = 'LOG',
	@Compress = 'Y',
	@Encrypt = 'Y',
	@EncryptionAlgorithm = 'AES_256',
	@ServerCertificate = 'backups_cert',
	@CleanupTime = 48,
	@DirectoryStructure = '{DatabaseName}{DirectorySeparator}{BackupType}',
	@FileName = '{DatabaseName}_{BackupType}_{Year}{Month}{Day}_{Hour}{Minute}{Second}_{FileNumber}.{FileExtension}',
	@LogToTable = 'Y';

-------------------------------------------------
--      Index and statistics maintenance
-------------------------------------------------

EXECUTE _dba.dbo.IndexOptimize 
	@Databases = 'USER_DATABASES',
	@FragmentationLow = NULL,
	@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
	@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
	@FragmentationLevel1 = 5,
	@FragmentationLevel2 = 30,
	@SortInTempdb = 'Y',
	@MaxDOP = 2,
	@LogToTable = 'Y',
	@MinNumberOfPages = 10,
	@UpdateStatistics = 'ALL',
	@OnlyModifiedStatistics = 'Y',
	@StatisticsSample = 100 -- FULL SCAN

-------------------------------------------------
--      Statistics only maintenance
-------------------------------------------------

EXECUTE _dba.dbo.IndexOptimize 
	@Databases = 'USER_DATABASES',
	@FragmentationLow = NULL,
	@FragmentationMedium = NULL,
	@FragmentationHigh = NULL,
	@MaxDOP = 2,
	@LogToTable = 'Y',
	@UpdateStatistics = 'ALL',
	@OnlyModifiedStatistics = 'Y'
	--,@StatisticsSample = 100 -- FULL SCAN


-------------------------------------------------
--         Clean up commandLog table
-------------------------------------------------

DELETE FROM _dba.dbo.CommandLog 
WHERE StartTime < DATEADD(day,-30,CURRENT_TIMESTAMP);