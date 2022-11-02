-----------------------------------------------------------------
-- AlwaysOn AG backups with Ola Hallengren procedures
-- Useful only if you are on a AlwaysOn Availability Group
--
-- change @Directory value
--
-- rudi@babaluga.com, go ahead license
-----------------------------------------------------------------

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-------------------------------------------------
--        Full backups for AG databases
-------------------------------------------------

EXECUTE _dba.dbo.DatabaseBackup 
	@Databases = 'AVAILABILITY_GROUP_DATABASES',
	@Directory = '\\backup-share\backups', -- change here
	@BackupType = 'FULL',
	@CopyOnly = 'Y',
	@Compress = 'Y',
	--@Encrypt = 'Y',
	--@EncryptionAlgorithm = 'AES_256',
	--@ServerCertificate = 'backup_cert', -- change here
	@CleanupTime = 24,
	@AvailabilityGroupDirectoryStructure = '{AvailabilityGroupName}{DirectorySeparator}{DatabaseName}{DirectorySeparator}{BackupType}_{CopyOnly}',
	@AvailabilityGroupFileName = '{DatabaseName}_{BackupType}_{Year}{Month}{Day}_{Hour}{Minute}{Second}_{FileNumber}.{FileExtension}',
	@LogToTable = 'Y';

/* INFO :

You cannot use both options :
- @CleanupTime
- @CopyOnly = 'Y'

Without mentionning {CopyOnly} in the @DirectoryStructure parameter.

There is a check in Ola Hallengren's code to prevent cleanup 
(https://github.com/olahallengren/sql-server-maintenance-solution/issues/440#issuecomment-739360072)

  IF @CleanupTime IS NOT NULL AND @CopyOnly = 'Y' AND ((@DirectoryStructure NOT LIKE '%{CopyOnly}%' OR @DirectoryStructure IS NULL) OR (SERVERPROPERTY('IsHadrEnabled') = 1 AND (@AvailabilityGroupDirectoryStructure NOT LIKE '%{CopyOnly}%' OR @AvailabilityGroupDirectoryStructure IS NULL)))
  BEGIN
    INSERT INTO @Errors ([Message], Severity, [State])
    SELECT 'The value for the parameter @CleanupTime is not supported. Cleanup is not supported if the token {CopyOnly} is not part of the directory.', 16, 7
  END

So, don't remove this token.

*/

-------------------------------------------------
--        Full backups for other databases
-------------------------------------------------

EXECUTE _dba.dbo.DatabaseBackup 
	@Databases = 'USER_DATABASES, -AVAILABILITY_GROUP_DATABASES',
	@Directory = '\\backup-share\backups', -- change here
	@BackupType = 'FULL',
	@CopyOnly = 'N',
	@Compress = 'Y',
	--@Encrypt = 'Y',
	--@EncryptionAlgorithm = 'AES_256',
	--@ServerCertificate = 'backup_cert', -- change here
	--@CleanupTime = 24,
	@CleanupTime = 48,
	@DirectoryStructure = '{ServerName}{DirectorySeparator}{DatabaseName}{DirectorySeparator}{BackupType}',
	@FileName = '{DatabaseName}_{BackupType}_{Year}{Month}{Day}_{Hour}{Minute}{Second}_{FileNumber}.{FileExtension}',
	@LogToTable = 'Y';


-------------------------------------------------
--           Log backups
-------------------------------------------------

EXECUTE _dba.dbo.DatabaseBackup 
	@Databases = 'USER_DATABASES',
	@Directory = '\\backup-share\backups',
	@BackupType = 'LOG',
	@Compress = 'Y',
	--@Encrypt = 'Y',
	--@EncryptionAlgorithm = 'AES_256',
	--@ServerCertificate = 'backup_cert',
	@CleanupTime = 24,
	@DirectoryStructure = '{DatabaseName}{DirectorySeparator}{BackupType}',
	@AvailabilityGroupDirectoryStructure = '{AvailabilityGroupName}{DirectorySeparator}{DatabaseName}{DirectorySeparator}{BackupType}_{CopyOnly}',
	@FileName = '{DatabaseName}_{BackupType}_{Year}{Month}{Day}_{Hour}{Minute}{Second}_{FileNumber}.{FileExtension}',
	@AvailabilityGroupFileName = '{DatabaseName}_{BackupType}_{Year}{Month}{Day}_{Hour}{Minute}{Second}_{FileNumber}.{FileExtension}',
	@LogToTable = 'Y';

