-------------------------------------------------------------------------------
-- get detailed SQL Server version information
-- rudi@babaluga.com, go ahead license
-------------------------------------------------------------------------------

-- retrieving detailed SQL Server version information
SELECT 
	SERVERPROPERTY('ProductVersion') AS ProductVersion,
	SERVERPROPERTY('ProductMajorVersion') AS ProductMajorVersion,
	SERVERPROPERTY('ProductMinorVersion') AS ProductMinorVersion,	
	SERVERPROPERTY('ProductBuild') AS ProductBuild,
	SERVERPROPERTY('Edition') AS Edition,
	SERVERPROPERTY('ProductLevel') AS ProductLevel,
	SERVERPROPERTY('ProductUpdateLevel') AS ProductUpdateLevel,
	SERVERPROPERTY('ProductUpdateReference') AS ProductUpdateReference,
	CAST(CONCAT('https://support.microsoft.com/en-us/help/', STUFF(CAST(SERVERPROPERTY('ProductUpdateReference') AS VARCHAR(20)), 1, 2, '')) as XML) AS KB_Address,
	CAST(SERVERPROPERTY('ResourceLastUpdateDateTime') AS DATETIME2(0)) AS ResourceLastUpdateDateTime, -- Returns the date and time that the Resource database was last updated.
	SERVERPROPERTY('ResourceVersion') AS ResourceVersion,
	SERVERPROPERTY('BuildClrVersion') AS BuildClrVersion;